class TagsController < ApplicationController
  before_action :set_tag, only: %i[show edit update destroy]

  # GET /tags
  # GET /tags.json
  def index
    # NOTE: Pulling tags only for the owner passed in
    @tags = Tag.where(group: tag_params[:group]).order(:name)
    # @tags = @tags.to_a.reject!{ |t| t['is_archived'] == true} unless params[:include_archived].present? && params[:include_archived] == 'true'

    if @tags
      render json: @tags.as_json(
        only: [],
        methods: %i[id name taggings_count]
      )
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@tags)
      }, status: 422
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    if @tag
      render json: @tag.as_json(
        only: [],
        methods: %i[id name taggings_count]
      )
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@tag)
      }, status: 422
    end
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit; end

  # POST /tags
  # POST /tags.json
  def create
    tp = tag_params

    # NOTE: associate tag to user/group
    @tag = Tag.find_or_create_by(
      name: tp[:name].downcase,
      group: tp[:group]
    )

    if @tag.valid?

      render json: @tag.as_json(
        only: [],
        methods: %i[id name taggings_count]
      )
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@tag)
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    tp = tag_params
    # Only update the name group
    if @tag.update(name: tp[:name].downcase)
      render json: @tag.as_json(
        only: [],
        methods: %i[id name taggings_count]
      ), status: :ok
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@tag)
      }, status: :unprocessable_entity
  end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    if @tag.present? && @tag.has_media?
      return render(json: {
                      errors: Stitches::Errors.new(
                        [
                          Stitches::Error.new(code: 'invalid_state', message: 'Can not delete tags that have media associated to them. Please remove all media from tag first.')
                        ]
                      )
                    }, status: :unprocessable_entity)
    end

    # # NOTE: due to the option to archive instead of just a delete, we need to do
    # # a slightly different validity check...
    # it_worked = false
    # if tag_params[:status].present?
    #   it_worked = @tag.update(is_archived: true)
    # else
    #   it_worked = @tag.destroy
    # end

    if @tag.destroy
      head :no_content
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@tag)
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
    unless @tag.present? && (@tag.group == tag_params[:group])
      render(json: {
               errors: Stitches::Errors.new(
                 [
                   Stitches::Error.new(code: 'not_found', message: 'The tags was not found')
                 ]
               )
             }, status: :unprocessable_entity) && return
    end
    @tag
  end

  # def set_user
  #   app_key = request.headers['Authorization']
  #   @user = "#{params[:owner]}:#{app_key.gsub('StackedSportsAuthKey key=', '')}"
  # end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:name, :owner, :group, :status)
  end
end
