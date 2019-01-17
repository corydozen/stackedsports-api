class ApplicationController < ActionController::Base
  include Sorcery::Controller

  before_action :require_login

  def authenticate
    current_user || not_authenticated
  end

  def not_authenticated
    respond_to do |type|
      type.html { redirect_to login_path, alert: 'Please login first' }
      type.json { render json: { errors: 'Unable to authenticate' }, status: :unauthorized }
    end
  end

  def unable_to_activate
    render json: { errors: 'User already activated or not found' }, status: :unprocessable_entity
  end
end
