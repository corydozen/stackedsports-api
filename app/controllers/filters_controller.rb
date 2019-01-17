class FiltersController < ApplicationController
  # skip_before_action :require_login
  before_action :set_filter, only: %i[show edit update destroy]

  # GET /filters
  # GET /filters.json
  def index
    @filters = Filter.all
  end

  # GET /filters/1
  # GET /filters/1.json
  def show; end

  # GET /filters/new
  def new
    @filter = Filter.new
  end

  # GET /filters/1/edit
  def edit; end

  # POST /filters
  # POST /filters.json
  def create
    # 'on' is passed from the bulma checkbox...
    is_shared = params[:is_shared] == 'on'
    @filter = Filter.new(filter_params.merge(user_id: current_user.id, team_id: current_user.teams.first.id, is_shared: is_shared))

    # Add new filterable_types here
    redirect_path = case filter_params[:filterable_type]
                    when 'TeamAthlete'
                      athletes_path
                    when 'Medium'
                      media_path
                    end

    respond_to do |format|
      if @filter.save
        format.html { redirect_to redirect_path, notice: 'Filter was successfully created.' }
        format.json { render :show, status: :created, location: @filter }
      else
        format.html { redirect_to redirect_path, flash: { error: "Filter was not created due to #{@filter.errors.messages}" } }
        format.json { render json: @filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /filters/1
  # PATCH/PUT /filters/1.json
  def update
    respond_to do |format|
      if @filter.update(filter_params)
        format.html { redirect_to @filter, notice: 'Filter was successfully updated.' }
        format.json { render :show, status: :ok, location: @filter }
      else
        format.html { render :edit }
        format.json { render json: @filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /filters/1
  # DELETE /filters/1.json
  def destroy
    @filter.destroy
    respond_to do |format|
      format.html { redirect_to filters_url, notice: 'Filter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_filter
    @filter = Filter.find_by(id: params[:id], user_id: current_user.id, team_id: current_user.teams.first.id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def filter_params
    params.require(:filter).permit(:name, :is_shared, :filterable_type, :criteria)
  end
end
