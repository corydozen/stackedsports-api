class AthletesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_athlete, only: %i[show edit update destroy add_owned_tag remove_owned_tag report active_hours active_days program_engagement coach_engagement sentiment_analysis]

  # GET /athletes
  # GET /athletes.json
  def index
    # This is here to instantiate the athlete in the modal
    @athlete = Athlete.new
    @filter = Filter.new
    @results = { athletes: [], twitter: [] }

    per_page = params[:per_page] || 10
    @athletes = TeamAthlete.search(params[:search], current_user.teams.first.id)

    # Filter vars
    @years = @athletes.where.not(graduation_year: nil).group_by_year(:graduation_year, time_zone: false, format: '%Y', series: false).count
    # Hash[@athletes.keep_if { |a| a.graduation_year.present? }.group_by_year(time_zone: false, format: '%Y', &:graduation_year).map { |k, v| [k, v.size] }]
    @states = @athletes.each_with_object(Hash.new(0)) { |v, h| h[v.state] += 1 if v.state.present?; }

    positions = []
    @athletes.each { |a| a.positions.each { |p| positions << p } if a.positions.present? }
    @offense_total = positions.each_with_object(Hash.new(0)) { |v, h| h[v.group] += 1 if v.group == 'offense'; }
    @offense = positions.each_with_object(Hash.new(0)) { |v, h| h[v.name] += 1 if v.group == 'offense'; }
    @defense_total = positions.each_with_object(Hash.new(0)) { |v, h| h[v.group] += 1 if v.group == 'defense'; }
    @defense = positions.each_with_object(Hash.new(0)) { |v, h| h[v.name] += 1 if v.group == 'defense'; }
    @special_total = positions.each_with_object(Hash.new(0)) { |v, h| h[v.group] += 1 if v.group == 'special'; }
    @special_teams = positions.each_with_object(Hash.new(0)) { |v, h| h[v.name] += 1 if v.group == 'special'; }

    @athletes = @athletes.sort_by { |k| k[sort_column.to_sym] }

    @athletes = @athletes.paginate(page: params[:page], per_page: per_page) # .order("#{sort_column} #{sort_direction}")
  end

  # GET /athletes/1
  # GET /athletes/1.json
  def show
    current_user.update_twitter_profile(@athlete.athlete.twitter_profile)
    @message = Message.new
    @athlete
    @conversation = @athlete.get_conversation(current_user)
    @report = nil
  end

  # GET /athletes/new
  def new
    @athlete = Athlete.new
  end

  # GET /athletes/1/edit
  def edit; end

  # POST /athletes
  # POST /athletes.json
  def create
    # clear unaccepted params from athlete

    # NOTE: Not using the athlete_params because it is tied to the team_athlete
    ap = params[:athlete]
    twitter_search = ap[:twitter_search]
    team_id = ap[:team_id]
    athlete_id = ap[:athlete_id]
    twitter_id = ap[:twitter_id]
    follow_on_twitter = ap[:follow_on_twitter]

    ap.delete :athlete_id
    ap.delete :team_id
    ap.delete :twitter_id
    ap.delete :follow_on_twitter
    ap.delete :twitter_search

    # check is athlete_id is present and search
    athlete = Athlete.find(athlete_id) if athlete_id.present?

    if athlete.present?
      # create the team_athlete record
      team_athlete = TeamAthlete.create(
        team_id: current_user.teams.first.id,
        athlete_id: athlete.id,
        first_name: ap[:first_name],
        last_name: ap[:last_name],
        nick_name: ap[:nick_name],
        phone: ap[:phone],
        email: ap[:email],
        high_school: ap[:high_school],
        state: ap[:state],
        coach_name: ap[:coach_name],
        mothers_name: ap[:mothers_name],
        fathers_name: ap[:fathers_name],
        graduation_year: ap[:graduation_year]
      )
      team_athlete.positions.add(ap[:position], parse: true) if ap[:position].present?
    else

      raise StandardError.new('Unable to create athlete, missing TwitterProfile') && return unless twitter_id.present?

      # we need to find or create the twitter_profile
      tp = TwitterProfile.find_or_create_by(twitter_id: twitter_id)
      current_user.update_twitter_profile(tp)

      begin
        # now that we have a twitter profile let's double check this athlete doesn't by twitter_profile_id
        athlete = Athlete.find_by(twitter_profile_id: tp.id)
      rescue StandardError
      end
      # we're creating a new athlete record and then
      athlete ||= Athlete.new(
        first_name: ap[:first_name],
        last_name: ap[:last_name],
        nick_name: ap[:nick_name],
        phone: ap[:phone],
        email: ap[:email],
        high_school: ap[:high_school],
        state: ap[:state],
        coach_name: ap[:coach_name],
        mothers_name: ap[:mothers_name],
        fathers_name: ap[:fathers_name],
        grad_year: ap[:graduation_year],
        graduation_year: Date.parse("#{ap[:graduation_year]}-05-01"),
        twitter_profile_id: tp.id
      )
      athlete.positions.add(ap[:position], parse: true) if ap[:position].present?
      athlete.save!

      team_athlete = TeamAthlete.find_or_create_by(
        team_id: current_user.teams.first.id,
        athlete_id: athlete.id
      )
      team_athlete.update(
        first_name: ap[:first_name],
        last_name: ap[:last_name],
        nick_name: ap[:nick_name],
        phone: ap[:phone],
        email: ap[:email],
        high_school: ap[:high_school],
        state: ap[:state],
        coach_name: ap[:coach_name],
        mothers_name: ap[:mothers_name],
        fathers_name: ap[:fathers_name],
        graduation_year: ap[:graduation_year]
      )
      team_athlete.positions.add(ap[:position], parse: true) if ap[:position].present?
    end

    # follow on twitter if needed
    current_user.follow_on_twitter(athlete) if follow_on_twitter.present?

    respond_to do |format|
      # ultimately there should have been a team_athlete record created
      if team_athlete.valid?
        format.html { redirect_to athletes_path, success: 'Athlete was successfully created.' }
        format.json { render :show, status: :created, location: @athlete }
      else
        format.html { redirect_to athletes_path, error: 'Error occurred while creating athlete' }
        format.json { render json: @athlete.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /athletes/1
  # PATCH/PUT /athletes/1.json
  def update
    respond_to do |format|
      if @athlete.update(athlete_params)
        format.html { redirect_to @athlete, notice: 'Athlete was successfully updated.' }
        format.json { respond_with_bip(@athlete) }
      else
        format.html { render :edit }
        format.json { espond_with_bip(@athlete) }
      end
    end
  end

  # DELETE /athletes/1
  # DELETE /athletes/1.json
  def destroy
    @athlete.destroy
    respond_to do |format|
      format.html { redirect_to athletes_url, notice: 'Athlete was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def filter
    per_page = params[:per_page] || 10

    if params[:filter].present?
      # Set all params based on saved filter
      filter = Filter.find(params[:filter])
      # make sure this filter belongs to the user or team
      filter = nil unless filter.filterable_type == 'TeamAthlete' && (filter.user_id == current_user.id || filter.team_id == current_user.teams.first.id)
      criteria = JSON.parse(filter.criteria) if filter.present?
      # p criteria

      if criteria.present?
        search = criteria['search'] if criteria['search'].present?
        years = criteria['years'].join(',') if criteria['years'].present?
        states = criteria['states'].map { |str| "\'#{str}\'" }.join(',') if criteria['states'].present?
        positions = criteria['positions'] if criteria['positions'].present?
        position_types = criteria['position_type'] if criteria['position_type'].present?
        tags = criteria['tags'] if criteria['tags'].present?
      end
    end

    # Otherwise just sent based on params passed in
    search ||= params[:search] if params[:search].present?
    years ||= params[:years].join(',') if params[:years].present?
    states ||= params[:states].map { |str| "\'#{str}\'" }.join(',') if params[:states].present?
    positions ||= params[:positions]
    position_types ||= params[:position_type]
    tags ||= params[:tags]

    athletes = TeamAthlete.where(team_id: current_user.teams.first.id)
    athletes = athletes.search(search, current_user.teams.first.id) if search.present?
    athletes = athletes.where("extract(year from graduation_year) in (#{years})") if years.present?
    athletes = athletes.where("state in (#{states})") if states.present?
    athletes = athletes.tagged_with(positions, on: :positions, any: true) if positions.present?

    position_type_tags = Tag.where(group: position_types.map!(&:downcase)).pluck(:name) if position_types.present?
    athletes = athletes.tagged_with(position_type_tags, any: true) if position_type_tags.present?

    athletes = athletes.tagged_with(tags, any: true) if tags.present?

    @athletes = athletes.paginate(page: params[:page], per_page: per_page).order("#{sort_column} #{sort_direction}")
    respond_to do |format|
      format.js {}
    end
  end

  def search
    @current_athletes = current_user.teams.first.athletes.pluck(:athlete_id)
    @current_athlete_twitter_ids = []
    current_user.teams.first.athletes.map { |team_athlete| @current_athlete_twitter_ids << team_athlete.athlete.twitter_profile.id }
    @results = Athlete.search(params[:search], return_all: false, user_to_search_twitter_with: current_user, only_search_twitter: true)
    respond_to do |format|
      format.js {}
    end
  end

  def add_owned_tag
    owned_tag_list = @athlete.all_tags_list - @athlete.tag_list
    owned_tag_list += [params[:tag]]
    current_user.tag(@athlete, with: stringify(owned_tag_list), on: :tags)
    @athlete.save
  end

  def remove_owned_tag
    owned_tag_list = @athlete.all_tags_list - @athlete.tag_list
    owned_tag_list -= [params[:tag]]
    current_user.tag(@athlete, with: stringify(owned_tag_list), on: :tags)
    @athlete.save
  end

  # Report methods
  def report; end

  def active_hours
    render json: AthleteReport.active_hours(@athlete.athlete, cookies['browser.timezone'])
  end

  def active_days
    render json: AthleteReport.active_days(@athlete.athlete, cookies['browser.timezone'])
  end

  def program_engagement
    render json: AthleteReport.program_engagement(@athlete.athlete)
  end

  def coach_engagement
    render json: AthleteReport.coach_engagement(@athlete.athlete)
  end

  def sentiment_analysis
    render json: AthleteReport.sentiment_analysis(@athlete.athlete)
  end

  private

  def stringify(tag_list)
    tag_list.inject('') { |memo, tag| memo += (tag + ',') }[0..-1]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_athlete
    @athlete = TeamAthlete.find(params[:id]) if params[:id].present?
    @athlete = TeamAthlete.find(params[:athlete_id]) if params[:athlete_id].present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def athlete_params
    params.require(:team_athlete).permit(:twitter_search, :twitter_id, :follow_on_twitter, :first_name, :last_name, :nick_name, :phone, :email, :high_school, :state, :coach_name, :mothers_name, :fathers_name, :position, :positions, :graduation_year, :hudl_id, :arms_id, :athlete_id, :team_id)
  end

  def sortable_columns
    %w[first_name last_name twitter phone last_messaged last_report most_active_day most_active_time]
  end

  def sort_column
    sortable_columns.include?(params[:column]) ? params[:column] : 'first_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
