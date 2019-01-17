class MediaController < ApplicationController
  before_action :set_medium, only: %i[show edit update destroy archive add_tag remove_tag]

  def search
    @params_tags = params[:tags].present? ? params[:tags].downcase.split(',') : []
    @media = Medium.where(owner: current_user.id).or(Medium.where(group: current_user.teams.first.id))

    @media = @media.where('lower(name) like ?', "%#{params[:name].downcase}%") if params[:name].present?

    @media = @media.where('lower(object_content_type) like ?', "%#{params[:type].downcase}%") if params[:type].present?

    @media = @media.tagged_with(params[:tags].downcase.split(',')) if params[:tags].present?

    @media
  end

  # GET /media
  # GET /media.json
  def index
    @params_tags = params[:tags].present? ? params[:tags].downcase.split(',') : []
    @team_media = Medium.where(owner: current_user.id).or(Medium.where(group: current_user.teams.first.id))
    @images = @team_media.where("lower(object_content_type) like '%image%' and lower(object_content_type) not like '%gif%'")
    @gifs = @team_media.where("lower(object_content_type) like '%gif%'")
    @videos = @team_media.where("lower(object_content_type) like '%video%'")
    @my_media = Medium.where(owner: current_user.id)

    @media = @team_media
    @media = @my_media if params[:only_mine].present?

    @media = Medium.where(owner: current_user.id).or(Medium.where(group: current_user.teams.first.id))

    @media = @media.where('lower(name) like ?', "%#{params[:name].downcase}%") if params[:name].present?

    @media = @media.where('lower(object_content_type) like ?', "%#{params[:type].downcase}%") if params[:type].present?

    @media = @media.tagged_with(params[:tags].downcase.split(',')) if params[:tags].present?

    @media
  end

  # GET /media/1
  # GET /media/1.json
  def show; end

  # GET /media/new
  def new
    @medium = Medium.new
  end

  # GET /media/1/edit
  def edit
    @team_media = Medium.where(group: current_user.teams.first.id)
    @images = @team_media.where("lower(object_content_type) like '%image%' and lower(object_content_type) not like '%gif%'")
    @gifs = @team_media.where("lower(object_content_type) like '%gif%'")
    @videos = @team_media.where("lower(object_content_type) like '%video%'")
    @my_media = Medium.where(owner: current_user.id)
  end

  # POST /media
  # POST /media.json
  def create
    mp = {}
    mp[:object] = params[:object]
    oauth_token = current_user.social_accounts.primary.twitter.first.oauth_token
    oauth_secret = current_user.social_accounts.primary.twitter.first.oauth_secret
    mp[:owner] = current_user.id
    mp[:group] = current_user.teams.first.id

    mp[:name] = params[:object].original_filename unless mp[:name].present?

    # @medium = Medium.create(mp)
    @medium = Medium.new(mp)

    respond_to do |format|
      if @medium.save
        # UploadMediaToTwitterJob.perform_later(@medium, oauth_token, oauth_secret)
        format.js { render json: @medium.id, status: :created }
        format.html { redirect_to @medium, notice: 'Medium was successfully created.' }
        format.json { render :show, status: :created, location: @medium }
      else
        format.html { render :new }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media/1
  # PATCH/PUT /media/1.json
  def update
    Stitches::Error.new(code: 'invalid_state', message: 'Can not edit media that has been sent in message') && return if @medium.present? && @medium.has_been_sent?

    mp = medium_params
    if mp[:object]
      mp[:name] = mp[:object].original_filename unless mp[:name].present?
    end

    respond_to do |format|
      if @medium.update(mp)
        format.html { redirect_to @medium, notice: 'Medium was successfully updated.' }
        format.json { respond_with_bip(@medium) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@medium) }
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    Stitches::Error.new(code: 'invalid_state', message: 'Can not delete media that has been sent in message') && return if @medium.present? && @medium.has_been_sent?
    @medium.destroy
    respond_to do |format|
      format.js { head :ok }
      format.html { redirect_to media_url, notice: 'Medium was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_tag
    unless @medium.present? && (@medium.owner == current_user.id.to_s || @medium.owner == current_user.teams.first.id.to_s)
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The media was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    unless params[:tag].present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    tag = Tag.find_or_create_by(name: params[:tag], group: current_user.teams.first.id)

    unless tag.present? && tag.group == current_user.teams.first.id.to_s
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    @medium.tag_list.add(tag.name)

    if @medium.save
      render(json: { current_tags: @medium.tags.map(&:name), tags: current_user.teams.first.tags.map(&:name) })
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(mt)
      }, status: :unprocessable_entity
    end
  end

  def remove_tag
    unless @medium.present? && (@medium.owner == current_user.id.to_s || @medium.owner == current_user.teams.first.id.to_s)
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The media was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    unless params[:tag].present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    tag = Tag.find_by(name: params[:tag], group: current_user.teams.first.id)

    unless tag.present? && tag.group == current_user.teams.first.id.to_s
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    @medium.tag_list.remove(tag.name)

    if @medium.save
      render(json: { current_tags: @medium.tags.map(&:name).sort, tags: current_user.teams.first.tags.map(&:name).sort })
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(mt)
      }, status: :unprocessable_entity
    end
  end

  def add_tags_to_multiple
    unless params[:media_ids]
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'A list of media must be present')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    unless params[:tag_list].present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    tag_list = params[:tag_list]
    tags = []
    tag_list.each do |_tag|
      tag = Tag.find_or_create_by(name: _tag.downcase, group: current_user.teams.first.id)
      tags << tag
    end

    unless tags.present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    media_ids = params[:media_ids]
    errors = []
    media_ids.each do |id|
      medium = Medium.find(id.to_i)
      next unless medium.present? && medium.owner == current_user.id.to_s && tags.present?

      begin
        tags.each do |tag|
          medium.tag_list.add(tag.name)
          medium.save!
        end
      rescue StandardError => exc
        errors << exc
      end
    end
    render(json: { errors: errors }) && return if errors.present?
    head :ok
  end

  # TODO
  def archive; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_medium
    @medium = Medium.find(params[:id]) if params[:id].present?
    @medium ||= Medium.find(params[:medium_id]) if params[:medium_id].present?
    return unless @medium.present? && (@medium.owner == current_user.id.to_s || @medium.group == current_user.teams.first.id.to_s)

    @medium
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def medium_params
    params.require(:medium).permit(:name, :object, :tag, :tag_list)
  end
end
