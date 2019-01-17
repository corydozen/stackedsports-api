class CoEmailRecipientsController < ApplicationController
  # skip_before_action :require_login
  before_action :set_co_email_recipient, only: [:show, :edit, :update, :destroy]

  # GET /co_email_recipients
  # GET /co_email_recipients.json
  def index
    @co_email_recipients = CoEmailRecipient.all
  end

  # GET /co_email_recipients/1
  # GET /co_email_recipients/1.json
  def show
  end

  # GET /co_email_recipients/new
  def new
    @co_email_recipient = CoEmailRecipient.new
  end

  # GET /co_email_recipients/1/edit
  def edit
  end

  # POST /co_email_recipients
  # POST /co_email_recipients.json
  def create
    @co_email_recipient = CoEmailRecipient.new(co_email_recipient_params)

    respond_to do |format|
      if @co_email_recipient.save
        format.html { redirect_to @co_email_recipient, notice: 'Co email recipient was successfully created.' }
        format.json { render :show, status: :created, location: @co_email_recipient }
      else
        format.html { render :new }
        format.json { render json: @co_email_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /co_email_recipients/1
  # PATCH/PUT /co_email_recipients/1.json
  def update
    respond_to do |format|
      if @co_email_recipient.update(co_email_recipient_params)
        format.html { redirect_to @co_email_recipient, notice: 'Co email recipient was successfully updated.' }
        format.json { render :show, status: :ok, location: @co_email_recipient }
      else
        format.html { render :edit }
        format.json { render json: @co_email_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /co_email_recipients/1
  # DELETE /co_email_recipients/1.json
  def destroy
    @co_email_recipient.destroy
    respond_to do |format|
      format.html { redirect_to co_email_recipients_url, notice: 'Co email recipient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_co_email_recipient
      @co_email_recipient = CoEmailRecipient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def co_email_recipient_params
      params.require(:co_email_recipient).permit(:email, :full_name, :enabled)
    end
end
