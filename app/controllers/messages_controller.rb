class MessagesController < ApplicationController
  before_action :set_message, only: %i[show edit update destroy]

  # GET /inboxes
  # GET /inboxes.json
  def inbox
    # NOTE: this function utilizes the Postgres specific function `json_build_object`
    build_inbox
  end

  def conversation
    build_inbox
    @sms_messages = SmsEvent.where(user_id: current_user.id, team_athlete_id: params[:athlete_id])
  end

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.where(user_id: current_user.id).or(Message.where(team_id: current_user.teams.first.id)).where.not(status: 'deleted').includes(:message_recipients).status_order.order('message_recipients.send_at')
    # NOTE: Remove archived messages unless explicitly requested
    @messages = @messages.to_a.reject! { |m| m['status'] == 'archived' } if params[:include_archived].present? && params[:include_archived] != 'true'
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @inbox = []
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit; end

  # POST /messages
  # POST /messages.json
  def create
    # Merge user_id and team_id from current_user
    mp = message_params.merge(user_id: current_user.id, team_id: current_user.teams.first.id)
    send_at = message_params[:send_at].to_time(:utc)
    mp.delete :send_at

    # Set platform and delete string param
    platform = Platform.find_by(name: message_params[:platform])
    mp.delete :platform

    mp[:status] = 'Pending'
    if message_params[:recipients].present?
      recipients = message_params[:recipients]
      # NOTE: we need to remove the recipients from the message params because the messages table doesn't have that field
      mp.delete :recipients
    end

    @message = Message.create(mp)

    respond_to do |format|
      if @message.valid?
        recipients.split(',').each do |recipient|
          # NOTE: Spliting the recipient on :: so the UI can send the recipient along with a grouping id

          # The team_athlete id should have been passed so we need to look up the athlete based on that id, and then find the twitter_profile

          ta = TeamAthlete.find(recipient.split('::')[0])

          next unless ta.present?
          MessageRecipient.create(
            message_id: @message.id,
            athlete_id: ta.athlete.id,

            # In a future version this will be a filter id...
            grouping: (recipient.split('::')[1] if recipient.split('::')[1].present?),
            name: (recipient.split('::')[2] if recipient.split('::')[2].present?),
            # If the recipient contains it's own send_at then use it otherwise use the message's send_at
            send_at: (recipient.split('::')[3].present? ? recipient.split('::')[3] : send_at),
            platform_id: platform.id
          )
        end
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients]), status: :created }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    # Return error if message is not pending

    unless @message.current_status == 'Pending'
      return render(json: {
                      errors: Stitches::Errors.new(
                        [
                          Stitches::Error.new(code: 'invalid_state', message: 'Can not edit a message unless it is pending')
                        ]
                      )
                    }, status: :unprocessable_entity)
    end

    mp = message_params # .merge(sender: @user)
    # Set platform and delete string param
    if message_params[:platform].present?
      platform = Platform.find_by(name: message_params[:platform])
      mp.delete :platform
    end

    if message_params[:send_at].present?
      send_at = message_params[:send_at].to_time(:utc)
      mp.delete :send_at
    end
    if message_params[:recipients].present?
      recipients = message_params[:recipients]
      # NOTE: we need to remove the recipients from the message params because the messages table doesn't have that field
      mp.delete :recipients
    end
    @message.update(mp)

    respond_to do |format|
      if @message.valid?
        # NOTE: Blow out all recipients if the param is present and recreate
        if recipients.present?
          MessageRecipient.where(message_id: @message.id).destroy_all
          recipients.split(',').each do |recipient|
            # NOTE: Spliting the recipient on :: so the UI can send the recipient along with a grouping id

            # The team_athlete id should have been passed so we need to look up the athlete based on that id, and then find the twitter_profile
            ta = TeamAthlete.find(recipient.split('::')[0])

            next unless ta.present?
            MessageRecipient.create(
              message_id: @message.id,
              athlete_id: ta.athlete.id,

              # In a future version this will be a filter id...
              grouping: (recipient.split('::')[1] if recipient.split('::')[1].present?),
              name: (recipient.split('::')[2] if recipient.split('::')[2].present?),
              # If the recipient contains it's own send_at then use it otherwise use the message's send_at
              send_at: (recipient.split('::')[3].present? ? recipient.split('::')[3] : send_at),
              platform_id: platform.id
            )
          end
        elsif !recipients.present? && send_at.present?
          # Only need to update the send at for the recipients
          @message.message_recipients.update(send_at: send_at)
        end
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    @message.message_recipients.where(status: 'pending').update_all(status: 'cancelled')
    @message.current_status
    @message.update(status: 'Cancelled')
    respond_to do |format|
      if @message.valid?
        format.js
        format.json { render json: @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients]), status: :ok }
      else
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    status = 'Deleted'
    status = 'Archived' if message_params[:status].present?
    # @message.destroy
    respond_to do |format|
      if @message.update(status: status)
        format.html { redirect_to messages_url, notice: 'Message was successfully removed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to messages_url, notice: 'Message was not removed.' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
    return unless @message.present? && (@message.user_id == current_user.id || @message.team_id == current_user.teams.first.id)
    @message
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:body, :media_id, :recipients, :send_at, :status, :user_id, :team_id, :platform)
  end
end

def build_inbox
  @inbox = current_user.get_inbox
end
