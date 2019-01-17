class Api::V1::OrganizationsController < Api::ApiController
  skip_before_action :require_login
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all
    render json: @organizations.as_json
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    if @organization
      render json: @organization.as_json
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@organization)
      }, status: 422
    end
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

      if @organization.save
        render json: @organization.as_json, status: :created
      else
        render json: {
          errors: Stitches::Errors.from_active_record_object(@organization)
        }, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
      if @organization.update(organization_params)
        render json: @organization.as_json
      else
        render json: {
          errors: Stitches::Errors.from_active_record_object(@organization)
        }, status: :unprocessable_entity
      end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    if @organization.present? && @organization.teams.present?
      return render(json: {
                      errors: Stitches::Errors.new(
                        [
                          Stitches::Error.new(code: 'invalid_state', message: 'Can not delete organization that has teams')
                        ]
                      )
                    }, status: :unprocessable_entity)
    end
    if @organization.destroy
      head :no_content
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(@organization)
      }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name, :phone, :address, :address_2, :city, :state, :zip, :stripe_customer_id)
    end
end
