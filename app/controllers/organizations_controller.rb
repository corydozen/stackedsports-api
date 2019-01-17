class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    per_page = params[:per_page] || 10
    per_page = Organization.count if params[:per_page] == 'ALL'
    @organizations = Organization.search(params[:search]).paginate(page: params[:page], per_page: per_page).order(:nickname)
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show; end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit; end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { respond_with_bip(@organization) }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@organization) }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    if @organization.present? && @organization.teams.present?
      redirect_to(organization_path, notice: 'Organization can not be delete if it has teams.') && return
    end
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def organization_params
    params.require(:organization).permit(:name, :nickname, :phone, :address, :address_2, :city, :state, :zip, :conference_id, :division, :stripe_customer_id, :logo, :primary_color, :secondary_color)
  end
end
