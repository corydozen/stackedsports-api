class UserSessionsController < ApplicationController
  skip_before_action :require_login # , except: %i[destroy]

  def new
    if logged_in?
      if current_user.is_admin?
        redirect_to(admin_path) && return
      else
        redirect_to(athletes_path) && return
      end
    end
    @user = User.new
  end

  def create
    # @user = login(params[:email], params[:password]) # User.authenticate(user_params[:email], user_params[:password]) # This method comes from Sorcery
    token = login_and_issue_token(params[:email], params[:password], params[:remember])
    respond_to do |format|
      # current_user = @user if @user.present?
      if current_user
        # token = Jwt::TokenProvider.call(user_id: @user.id)
        cookies.encrypted['X-AUTH-TOKEN'] = token
        if current_user.is_admin?
          format.html { redirect_back_or_to admin_path }
        else
          format.html { redirect_back_or_to athletes_path }
        end
        format.json { render 'api/v1/users/show', status: :ok } #  As an extra security metric, you might want to make sure you don’t send user’s encrypted password in `user: user` ;)
      else
        format.html { redirect_to login_path, alert: 'Login failed' }
        format.json { render json: { error: 'Login failed' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    logout
    # Seem to have to call this to completely clear the session
    reset_sorcery_session
    respond_to do |format|
      cookies.delete 'X-Auth-Token'
      format.html { redirect_to login_path, notice: 'Logged Out' }
      format.json { head :no_content }
    end
  end
end
