class SmsEventsController < ApplicationController
  skip_before_action :require_login
  # before_action :set_sms_event, only: %i[show edit update destroy]

  # GET /sms_events
  # GET /sms_events.json
  # def index
  #   @sms_events = SmsEvent.all
  # end

  # GET /sms_events/1
  # GET /sms_events/1.json
  # def show; end

  # GET /sms_events/new
  # def new
  #   @sms_event = SmsEvent.new
  # end

  # GET /sms_events/1/edit
  # def edit; end

  # POST /sms_events
  # POST /sms_events.json
  def create
    # Set foreign key based on direction
    if params[:direction] == 'out'
      user_id = SmsNumber.find_by(number: params[:from].delete('+')).user_id
      team_athlete_id = TeamAthlete.find_by(phone: params[:to].delete('+')).id
    elsif params[:direction] == 'in'
      user_id = SmsNumber.find_by(number: params[:to].delete('+')).user_id
      team_athlete_id = TeamAthlete.find_by(phone: params[:from].delete('+')).id
    end

    @sms_event = SmsEvent.new(
      event_type: params[:eventType],
      direction: params[:direction],
      from: params[:from].delete('+'),
      to: params[:to].delete('+'),
      message_id: params[:messageId],
      message_uri: params[:messageUri],
      text: params[:text],
      application_id: params[:applicationId],
      time: params[:time],
      state: params[:state],
      delivery_state: params[:deliveryState],
      delivery_code: params[:deliveryCode],
      delivery_description: params[:deliveryDescription],
      media: params[:media],
      tag: params[:tag],
      segment_count: params[:segmentCount],
      user_id: user_id,
      team_athlete_id: team_athlete_id
    )

    if @sms_event.save!
      head :ok
    else
      p @sms_event.errors
      head :unprocessable_entity
    end
  end

  # PATCH/PUT /sms_events/1
  # PATCH/PUT /sms_events/1.json
  # def update
  #   respond_to do |format|
  #     if @sms_event.update(sms_event_params)
  #       format.html { redirect_to @sms_event, notice: 'Sms event was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @sms_event }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @sms_event.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /sms_events/1
  # DELETE /sms_events/1.json
  # def destroy
  #   @sms_event.destroy
  #   respond_to do |format|
  #     format.html { redirect_to sms_events_url, notice: 'Sms event was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  # def set_sms_event
  #   @sms_event = SmsEvent.find(params[:id])
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sms_event_params
    params.permit(:eventType, :direction, :from, :to, :messageId, :messageUri, :text, :applicationId, :time, :state, :deliveryState, :deliveryCode, :deliveryDescription, :media, :tag, :segmentCount)
  end
end
