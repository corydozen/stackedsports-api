class ConferencesController < ApplicationController
  before_action :set_conference, only: [:show, :edit, :update, :destroy]

  # GET /conferences
  # GET /conferences.json
  def index
    per_page = params[:per_page] || 10
    @conferences = Conference.search(params[:search]).paginate( page: params[:page], per_page: per_page).order(:id)
  end

  # GET /conferences/1
  # GET /conferences/1.json
  def show
  end

  # GET /conferences/new
  def new
    @conference = Conference.new
  end

  # GET /conferences/1/edit
  def edit
  end

  # POST /conferences
  # POST /conferences.json
  def create
    @conference = Conference.new(conference_params)

    respond_to do |format|
      if @conference.save
        format.html { redirect_to @conference, notice: 'conference was successfully created.' }
        format.json { render :show, status: :created, location: @conference }
      else
        format.html { render :new }
        format.json { render json: @conference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conferences/1
  # PATCH/PUT /conferences/1.json
  def update
    respond_to do |format|
      if @conference.update(conference_params)
        format.html { redirect_to @conference, notice: 'conference was successfully updated.' }
        format.json { respond_with_bip(@conference) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@conference) }
      end
    end
  end

  # DELETE /conferences/1
  # DELETE /conferences/1.json
  def destroy
    if @conference.present? && @conference.organizations.present?
      redirect_to conference_path, notice: 'conference can not be delete if it has organizations.' and return
    end
    @conference.destroy
    respond_to do |format|
      format.html { redirect_to conferences_path, notice: 'conference was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conference
      @conference = Conference.find(params[:id])
    end

    def conference_params
      params.require(:conference).permit(:name, :is_power_five, :sort)
    end
end
