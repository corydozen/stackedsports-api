class Api::V2::MessagesController < Api::ApiController
  skip_before_action :require_login
  before_action :set_user
  before_action :set_message, only: %i[show edit update destroy cancel]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.where(sender: @user).or(Message.where(team: message_params[:team])).where.not(status: 'deleted').includes(:message_recipients).status_order.order('message_recipients.send_at')
    # NOTE: Remove archived messages unless explicitly requested
    @messages = @messages.to_a.reject! { |m| m['status'] == 'archived' } if params[:include_archived].present? && params[:include_archived] != 'true'

    if @messages
      render json: @messages.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients])
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@messages)
      }, status: 422
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    message = @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media])
    message['recipients'] = @message.recipients_full

    if message
      render json: message
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@message)
      }, status: 422
    end
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
    # NOTE: to ensure uniqueness of the messages as it relates to sender ids, the app_id should be stored on the message object as well
    mp = message_params.merge(sender: @user)
    send_at = message_params[:send_at].to_time(:utc)
    mp.delete :send_at
    mp[:status] = 'Pending'
    if message_params[:recipients].present?
      recipients = message_params[:recipients]
      # NOTE: we need to remove the recipients from the message params because the messages table doesn't have that field
      mp.delete :recipients
    end

    @message = Message.create(mp)

    if @message.valid?
      recipients.split(',').each do |recipient|
        # NOTE: Spliting the recipient on :: so the UI can send the recipient along with a grouping id
        next unless recipient.split('::')[0].present?

        MessageRecipient.create(
          message_id: @message.id,
          recipient: recipient.split('::')[0],
          grouping: (recipient.split('::')[1] if recipient.split('::')[1].present?),
          name: (recipient.split('::')[2] if recipient.split('::')[2].present?),
          # If the recipient contains it's own sent_at then use it otherwise use the message's send_at
          send_at: (recipient.split('::')[3].present? ? recipient.split('::')[3] : send_at),
          platform: 'twitter'
        )
      end
      render json: @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients]), status: :created
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@message)
      }, status: :unprocessable_entity
    end
  end

  def cancel
    @message.message_recipients.where(status: 'pending').update_all(status: 'cancelled')
    @message.current_status
    @message.update(status: 'Cancelled')
    if @message.valid?
      render json: @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients]), status: :ok
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@message)
      }, status: :unprocessable_entity
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

    mp = message_params.merge(sender: @user)
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
    if @message.valid?
      # NOTE: Blow out all recipients if the param is present and recreate
      if recipients.present?
        MessageRecipient.where(message_id: @message.id).destroy_all
        recipients.split(',').each do |recipient|
          # NOTE: Spliting the recipient on :: so the UI can send the recipient along with a grouping id
          next unless recipient.split('::')[0].present?

          MessageRecipient.create(
            message_id: @message.id,
            recipient: recipient.split('::')[0],
            grouping: (recipient.split('::')[1] if recipient.split('::')[1].present?),
            name: (recipient.split('::')[2] if recipient.split('::')[2].present?),
            # If the recipient contains it's own sent_at then use it otherwise use the message's send_at
            send_at: (recipient.split('::')[3].present? ? recipient.split('::')[3] : send_at),
            platform: 'twitter'
          )
        end
      elsif !recipients.present? && send_at.present?
        # Only need to update the send at for the recipients
        @message.message_recipients.update(send_at: send_at)
      end
      render json: @message.as_json(only: %i[], methods: %i[id sender body created_at updated_at first_sent_at last_sent_at next_send_at send_duration send_duration_readable current_status media recipients]), status: :ok
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@message)
      }, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    status = 'Deleted'
    status = 'Archived' if message_params[:status].present?
    if @message.update(status: status)
      head :no_content
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@message)
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
    unless @message.present? && (@message.sender == @user[0...@user.index(':')] || @message.team == message_params[:team])
      render(json: {
               errors: Stitches::Errors.new(
                 [
                   Stitches::Error.new(code: 'not_found', message: 'The message was not found')
                 ]
               )
             }, status: :unprocessable_entity) && return
    end
    @message
  end

  def set_user
    app_key = request.headers['Authorization']
    @user = "#{params[:sender]}:#{app_key.gsub('StackedSportsAuthKey key=', '')}"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:oauth_token, :oauth_secret, :body, :media_id, :sender, :team, :recipients, :send_at, :status)
  end
end
