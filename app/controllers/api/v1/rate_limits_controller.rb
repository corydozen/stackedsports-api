class Api::V1::RateLimitsController < Api::ApiController
skip_before_action :require_login
  def show
    respond_to do |format|
      format.json do
        if rate_limit_params[:error]
          render json: { errors: Stitches::Errors.new([ Stitches::Error.new(code: "422", message: rate_limit_params[:error]) ])} , status: 422
        else
          render json: RateLimitHelper.get_rate_limits(rate_limit_params[:oauth_token], rate_limit_params[:oauth_token_secret], rate_limit_params[:resources], rate_limit_params[:node]), status: :ok
        end
      end
    end
  end

private

  def rate_limit_params
    params.permit(:oauth_token, :oauth_token_secret, :resources, :node)
  end
end
