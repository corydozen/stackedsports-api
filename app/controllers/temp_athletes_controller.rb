class TempAthletesController < ApplicationController
  # skip_before_action :require_login
  before_action :set_temp_athlete, only: [:show, :edit, :update, :destroy]

  # GET /temp_athletes
  # GET /temp_athletes.json
  def index
    per_page = params[:per_page] || 10
    @temp_athletes = TempAthlete.search(params[:search]).paginate page: params[:page], per_page: per_page
  end

  # GET /temp_athletes/1
  # GET /temp_athletes/1.json
  def show
  end

  # GET /temp_athletes/new
  def new
    @temp_athlete = TempAthlete.new
  end

  # GET /temp_athletes/1/edit
  def edit
  end

  # POST /temp_athletes
  # POST /temp_athletes.json
  def create
    @temp_athlete = TempAthlete.new(temp_athlete_params)

    respond_to do |format|
      if @temp_athlete.save
        format.html { redirect_to @temp_athlete, notice: 'Temp athlete was successfully created.' }
        format.json { render :show, status: :created, location: @temp_athlete }
      else
        format.html { render :new }
        format.json { render json: @temp_athlete.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /temp_athletes/1
  # PATCH/PUT /temp_athletes/1.json
  def update
    respond_to do |format|
      if @temp_athlete.update(temp_athlete_params)
        format.html { redirect_to @temp_athlete, notice: 'Temp athlete was successfully updated.' }
        format.json { render :show, status: :ok, location: @temp_athlete }
      else
        format.html { render :edit }
        format.json { render json: @temp_athlete.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /temp_athletes/1
  # DELETE /temp_athletes/1.json
  def destroy
    @temp_athlete.destroy
    respond_to do |format|
      format.html { redirect_to temp_athletes_url, notice: 'Temp athlete was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_temp_athlete
      @temp_athlete = TempAthlete.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def temp_athlete_params
      params.fetch(:temp_athlete, {})
      params.require(:temp_athlete).permit(:first_name, :last_name, :positions, :grad_year, :address, :state, :twitter_handle, :email, :mobile, :city, :zip_code, :hs_name, :hs_state, :search)
    end
end
