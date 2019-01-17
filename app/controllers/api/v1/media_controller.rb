class Api::V1::MediaController < Api::ApiController
  skip_before_action :require_login
  before_action :set_medium, only: %i[show edit update destroy add_tag remove_tag]

  def search
    @media = Medium.where(owner: medium_params[:owner]).or(Medium.where(group: medium_params[:group]))

    @media = @media.where("lower(name) like ?", "%#{params[:name].downcase}%") if params[:name].present?

    @media = @media.where("lower(object_content_type) like ?", "%#{params[:type].downcase}%") if params[:type].present?

    if params[:tags].present?
      @media = @media.tagged_with(params[:tags].downcase.split(','))  #, match_all: true
    end

    if @media
      media = @media.as_json(
        only: [],
        methods: %i[id name created_at updated_at owner group file_name file_type size twitter_media_id urls tags messages]
      )

      render json: media
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@media)
      }, status: 422
    end
  end

  # GET /media
  # GET /media.json
  def index
    # NOTE: Pulling media only for the owner passed in
    @media = Medium.where(owner: medium_params[:owner]).or(Medium.where(group: medium_params[:group]))

    if @media
      media = @media.as_json(
        only: [],
        methods: %i[id name created_at updated_at owner group file_name file_type size twitter_media_id urls tags messages]
      )

      render json: media
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@media)
      }, status: 422
    end
  end

  # GET /media/1
  # GET /media/1.json
  def show
    if @medium
      medium = @medium.as_json(
        only: [],
        methods: %i[id name created_at updated_at owner group file_name file_type size twitter_media_id urls tags messages]
      )

      render json: medium
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@medium)
      }, status: 422
    end
  end

  # GET /media/new
  def new
    @medium = Medium.new
  end

  # GET /media/1/edit
  def edit; end

  # POST /media
  # POST /media.json
  def create
    mp = medium_params
    oauth_token = mp[:oauth_token]
    oauth_secret = mp[:oauth_secret]

    mp[:name] = mp[:object].original_filename unless mp[:name].present?

    @medium = Medium.create(mp)

    if @medium.valid?
      # , mp[:object].tempfile
      UploadMediaToTwitterJob.perform_later(@medium, oauth_token, oauth_secret)

      render json: @medium.as_json(
        only: [],
        methods: %i[id name created_at updated_at owner group file_name file_type size urls tags]
      )
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@medium)
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /media/1
  # PATCH/PUT /media/1.json
  def update
    # TODO: Add archive functionality...

    if @medium.present? && @medium.has_been_sent?
      return render(json: {
                      errors: Stitches::Errors.new(
                        [
                          Stitches::Error.new(code: 'invalid_state', message: 'Can not edit media that has been sent in message')
                        ]
                      )
                    }, status: :unprocessable_entity)
    end

    mp = medium_params
    oauth_token = mp[:oauth_token]
    mp.delete :oauth_token
    oauth_secret = mp[:oauth_secret]
    mp.delete :oauth_secret

    mp[:name] = mp[:object].original_filename unless mp[:name].present?
    @medium.update(mp)
    if @medium.valid?
      render json: @medium.as_json(
        only: [],
        methods: %i[id name created_at updated_at owner group file_name file_type size twitter_media_id urls tags]
      ), status: :ok
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@medium)
      }, status: :unprocessable_entity
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    if @medium.present? && @medium.has_been_sent?
      return render(json: {
                      errors: Stitches::Errors.new(
                        [
                          Stitches::Error.new(code: 'invalid_state', message: 'Can not delete media that has been sent in message')
                        ]
                      )
                    }, status: :unprocessable_entity)
    end

    if @medium.destroy
      head :no_content
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@medium)
      }, status: :unprocessable_entity
    end
  end

  def add_tag

    unless @medium.present? && (@medium.owner == medium_params[:owner] || @medium.owner == medium_params[:group])
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The media was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    unless medium_params[:tag].present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    tag = Tag.find_or_create_by(name: medium_params[:tag], group: medium_params[:group])

    unless tag.present? && tag.group == medium_params[:group]
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    @medium.tag_list.add(tag.name)

    if @medium.save
      head :created
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(mt)
      }, status: :unprocessable_entity
    end
  end

  def remove_tag

    unless @medium.present? && (@medium.owner == medium_params[:owner] || @medium.owner == medium_params[:group])
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The media was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    unless medium_params[:tag].present?
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    tag = Tag.find_by(name: medium_params[:tag], group: medium_params[:group])

    unless tag.present? && tag.group == medium_params[:group]
      render(json: { errors: Stitches::Errors.new(
        [
          Stitches::Error.new(code: 'not_found', message: 'The tag was not found')
        ]
      ) }, status: :unprocessable_entity) && return
    end

    @medium.tag_list.remove(tag.name)

    if @medium.save
      head :no_content
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(mt)
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_medium
    @medium = Medium.find(params[:id]) if params[:id].present?
    @medium ||= Medium.find(params[:medium_id]) if params[:medium_id].present?
    unless @medium.present? && (@medium.owner == medium_params[:owner] || @medium.group == medium_params[:group])
      render(json: {
               errors: Stitches::Errors.new(
                 [
                   Stitches::Error.new(code: 'not_found', message: 'The media was not found')
                 ]
               )
             }, status: :unprocessable_entity) && return
    end
    @medium
  end

  # def set_user
  #   app_key = request.headers['Authorization']
  #   @user = "#{params[:owner]}:#{app_key.gsub('StackedSportsAuthKey key=', '')}"
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  def medium_params
    params.require(:media).permit(:oauth_token, :oauth_secret, :name, :object, :owner, :group, :tag, :tag_list)
  end
end
