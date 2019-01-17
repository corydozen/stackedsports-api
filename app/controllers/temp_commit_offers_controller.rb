class TempCommitOffersController < ApplicationController
  # skip_before_action :require_login
  before_action :set_temp_commit_offer, only: %i[show edit update destroy]

  # GET /temp_commit_offers
  # GET /temp_commit_offers.json
  def index
    if TempCommitOffer.any?
      @as_of = TempCommitOffer.order(:created_at, :id).limit(1).first.created_at.to_date
      @temp_commit_offers = TempCommitOffer.where(deleted: false).order(created_at: :desc, recruit_name: :asc, program_name: :asc)
      @deleted_commit_offers = TempCommitOffer.where(deleted: true).order(created_at: :desc, recruit_name: :asc, program_name: :asc)
    end
  end

  # GET /temp_commit_offers/1
  # GET /temp_commit_offers/1.json
  def show; end

  # GET /temp_commit_offers/new
  def new
    @temp_commit_offer = TempCommitOffer.new
  end

  # GET /temp_commit_offers/1/edit
  def edit; end

  # POST /temp_commit_offers
  # POST /temp_commit_offers.json
  def create
    tcop = temp_commit_offer_params

    # NOTE: This is a remnant from a "hacky" way of sorting the select drop down due to a chrome issue
    tcop['organization_id'] = temp_commit_offer_params['organization_id'].gsub('org', '') if temp_commit_offer_params['organization_id'].present?
    tcop.delete 'organization_id' if tcop['organization_id'] == 0
    @temp_commit_offer = TempCommitOffer.new(temp_commit_offer_params)
    respond_to do |format|
      if @temp_commit_offer.save
        format.html { redirect_to temp_commit_offers_path, notice: 'Temp commit offer was successfully created.' }
        format.json { render :index, status: :created, location: @temp_commit_offer }
      else
        format.html { render :new }
        format.json { render json: @temp_commit_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /temp_commit_offers/1
  # PATCH/PUT /temp_commit_offers/1.json
  def update
    respond_to do |format|
      football_sport_id = Sport.find_by(name: 'Football')
      tcop = temp_commit_offer_params
      tcop['organization_id'] = nil if tcop['organization_id'] == '0'
      tcop['conference'] = nil unless tcop['organization_id'].present?
      if tcop['organization_id'].present?
        org = Organization.find(tcop['organization_id'])
        football_team = org.teams.find_by(sport_id: football_sport_id) if org.present?
        if football_team.present? && football_team.conference.present?
          tcop['conference'] = football_team.conference.name
        end
      end
      if @temp_commit_offer.update(tcop)
        begin
          # Try to find a temp athlete with the same twitter_handle and update it's data with the co email updates
          tp = TwitterProfile.find_by(screen_name: @temp_commit_offer.twitter_handle)
          athlete = Athlete.find_by(twitter_profile_id: tp.id) if tp.present?
          if athlete.present?
            athlete.grad_year = @temp_commit_offer.grad_year if @temp_commit_offer.grad_year.present?
            athlete.positions = @temp_commit_offer.position if @temp_commit_offer.position.present?
            athlete.state = @temp_commit_offer.state if @temp_commit_offer.state.present?
            athlete.hs_name = @temp_commit_offer.high_school if @temp_commit_offer.high_school.present?
            athlete.save
          end
        rescue StandardError => exc
          p exc
        end
        format.html { redirect_to temp_commit_offers_path, notice: 'Temp commit offer was successfully updated.' }
        # format.json { redirect_to temp_commit_offers_path,  notice: 'Temp commit offer was successfully updated.' }
        format.json { respond_with_bip(@temp_commit_offer) }
      else
        format.html { render :edit }
        # format.json { render json: @temp_commit_offer.errors, status: :unprocessable_entity }
        format.json { respond_with_bip(@temp_commit_offer) }
      end
    end
  end

  # DELETE /temp_commit_offers/1
  # DELETE /temp_commit_offers/1.json
  def destroy
    @temp_commit_offer.update(deleted: !@temp_commit_offer.deleted)
    respond_to do |format|
      format.html { redirect_to temp_commit_offers_url, notice: 'Temp commit offer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_selected
    tcos = params[:temp_commit_offer_ids]
    tcos.each do |tco|
      temp_co = TempCommitOffer.find(tco)
      temp_co.update(deleted: !temp_co.deleted)
    end
    respond_to do |format|
      format.html { redirect_to temp_commit_offers_url, notice: 'Temp commit offers were successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_daily_email
    render template: 'commit_offer_mailer/daily_email', layout: false # ).html_safe
  end

  def send_daily_email
    # Update org aliases
    aliasable_tcos = TempCommitOffer.where(deleted: false).where.not(organization_id: nil, program_name: nil).where.not(program_name: 'UNKNOWN')
    aliasable_tcos.each do |tco|
      OrganizationAlias.find_or_create_by(organization_id: tco.organization_id, alias: tco.program_name)
    end

    # Pull the email html into variable without the site layout
    email = (render_to_string template: 'commit_offer_mailer/daily_email', layout: false).html_safe

    # Get email settings
    co_email_settings = CoEmailSetting.first

    # Create new gibbon (MailChimp) request
    gibbon = Gibbon::Request.new

    # Create new template
    begin
      today = DateTime.now.to_date
      template = gibbon.templates.create(body: { name: "Offers & Commits Email (From #{today.strftime("%B #{today.day.ordinalize}, %Y")})", html: email.to_s })
    rescue Gibbon::MailChimpError => e
      puts "Houston, we have a template problem: #{e.message} - #{e.raw_body}"
    end

    begin
      # Create campaign to using new template
      recipients = { list_id: co_email_settings.list_id }
      settings = {
        subject_line: 'Recruit Suite Daily Offer & Commit Tweets',
        preview_text: 'Offers & Commits from RecruitSuite',
        title: "Offer Commit Emails #{today}",
        from_name: 'Christian Sanders',
        reply_to: 'christian@stackedsports.com'
      }

      body = { type: 'regular', recipients: recipients, settings: settings }
      campaign = gibbon.campaigns.create(body: body)
      # Update campaign with template
      template = { template: { id: template.body[:id] } }
      gibbon.campaigns(campaign.body[:id]).content.upsert(body: template)
      # Send email to campaign
      gibbon.campaigns(campaign.body[:id]).actions.send.create

      # Update sent_on for all sent records
      TempCommitOffer.where(deleted: false, sent_on: nil).update_all(sent_on: Time.now)
    rescue Gibbon::MailChimpError => e
      puts "Houston, we have an email problem: #{e.message} - #{e.raw_body}"
    end

    respond_to do |format|
      format.html { redirect_to temp_commit_offers_url, notice: 'Email sent.' }
      format.json { head :no_content }
      format.js { redirect_to temp_commit_offers_url, notice: 'Email sent.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_temp_commit_offer
    @temp_commit_offer = TempCommitOffer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def temp_commit_offer_params
    params.require(:temp_commit_offer).permit(:program_name, :recruit_name, :position, :grad_year, :high_school, :state, :twitter_handle, :tweet_text, :tweet_permalink, :deleted, :conference, :organization_id, :grouping, temp_commit_offer_ids: [])
  end
end
