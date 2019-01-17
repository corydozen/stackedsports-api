class Api::ApiController < ApplicationController # ActionController::Base
  include Stitches::Deprecation
  before_action :check_token

  def current_user
    @current_user ||= Jwt::UserAuthenticator.call(request.headers)
    # @current_user ||= Jwt::UserAuthenticator.call(cookies.encrypted['X-Auth-Token'])
    @current_user
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |type|
      type.json { render json: { errors: Stitches::Errors.new([Stitches::Error.new(code: 'not_found', message: exception.message)]) }, status: 404 }
      type.all  { render nothing: true, status: 404 }
    end
  end

  def check_token
    # NOTE: Check the cookies then check header
    @current_user ||= Jwt::UserAuthenticator.call(cookies.encrypted['X-Auth-Token'], true)
    # Not using cookies at the moment for lookup
    @current_user ||= Jwt::UserAuthenticator.call(request.headers)
  end

  protected

  def api_client
    @api_client ||= request.env[Stitches.configuration.env_var_to_hold_api_client]
    # Use this if you want to look up the ApiClient instead of using the one placed into the env
    # @api_client ||= ApiClient.find(request.env[Stitches.configuration.env_var_to_hold_api_client_primary_key])
  end
end
