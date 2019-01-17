class Api::V3::InboxesController < Api::ApiController
  # before_action :set_inbox, only: %i[update destroy]

  # GET /inboxes
  # GET /inboxes.json
  def index
    # NOTE: this function utilizes the Postgres specific function `json_build_object`
    sms_messages = SmsEvent.in_bound.where(user_id: current_user.id).joins(:team_athlete).group(
      "team_athletes.id,
      team_athletes.first_name,
      team_athletes.last_name,
      replace(sms_events.from, '+', '')"
    ).pluck(Arel.sql("json_build_object(
                       'team_athlete_id', team_athletes.id,
                       'first_name', team_athletes.first_name,
                       'last_name', team_athletes.last_name,
                       'message_type', 'sms',
                       'from', replace(sms_events.from, '+', ''),
                       'last_received_time', max(sms_events.time),
                       'unread', sum(case when sms_events.state = 'received' then 1 else 0 end),
                       'total', count(sms_events.*))"))

    sms_messages.each do |msg|
      msg[:last_message_preview] = SmsEvent.where(direction: 'in', team_athlete_id: msg['team_athlete_id'], user_id: current_user.id).order(time: :desc).first.text
    end

    @inbox = sms_messages
    # TODO: Build out twitter DM responses and merge them into @inbox
    render json: @inbox.sort_by { |msgs| msgs['last_received_time'] }.reverse.as_json if @inbox
  end

  # GET /inboxes/1
  # GET /inboxes/1.json
  # def show; end

  # POST /inboxes
  # POST /inboxes.json
  # def create
  #   @inbox = Inbox.new(inbox_params)
  #
  #   respond_to do |format|
  #     if @inbox.save
  #       format.html { redirect_to @inbox, notice: 'Inbox was successfully created.' }
  #       format.json { render :show, status: :created, location: @inbox }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @inbox.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /inboxes/1
  # PATCH/PUT /inboxes/1.json
  # def update
  #   respond_to do |format|
  #     if @inbox.update(inbox_params)
  #       format.html { redirect_to @inbox, notice: 'Inbox was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @inbox }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @inbox.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /inboxes/1
  # DELETE /inboxes/1.json
  # def destroy
  #   @inbox.destroy
  #   respond_to do |format|
  #     format.html { redirect_to inboxes_url, notice: 'Inbox was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  # private

  # Use callbacks to share common setup or constraints between actions.
  # def set_inbox
  #   begin
  #     @inbox = Inbox.find_by(user_id: current_user.id)
  #   rescue StandardError => exc
  #   end
  #
  #   unless @inbox.present? && (@inbox.user_id == current_user.id)
  #     render(json: {
  #              errors: Stitches::Errors.new(
  #                [
  #                  Stitches::Error.new(code: 'not_found', message: 'The inbox was not found this user')
  #                ]
  #              )
  #            }, status: :unprocessable_entity) && return
  #   end
  #
  #   @inbox
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def inbox_params
  #   params.fetch(:inbox, {})
  # end
end
