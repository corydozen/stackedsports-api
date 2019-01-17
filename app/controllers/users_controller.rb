class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create activate successful_view]
  before_action :set_user, only: %i[show edit update destroy]

  # def activate
  #
  # end

  def index
    if current_user.is_admin?
      per_page = params[:per_page] || 10
      @users = User.search(params[:search]).paginate(page: params[:page], per_page: per_page).order(:id)
    else
      @users = current_user.team.users
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  def successful_view; end

  # POST /users
  # POST /users.json
  def create
    up = user_params

    if up[:name].present?
      up[:first_name] = up[:name].split(' ')[0]
      up[:last_name] = up[:name].split(' ')[1]
      up.delete :name
    end
    @user = User.new(up)
    respond_to do |format|
      if @user.save
        # render json: {user: user, token: token}
        format.html { redirect_to :successful_view, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    if @user = User.load_from_activation_token(params[:id])

      @user.activate!
      @user.add_role :activated
      if @user.is_admin?
        env = case ENV['ENVIRONMENT']
              when 'dev'
                'http://localhost:3000'
              when 'test'
                'https://dev-stackedsports-api.herokuapp.com/dashboard'
              when 'prod'
                'https://stackedsports-api.herokuapp.com/dashboard'
              else
                'https://stackedsports-api.herokuapp.com/dashboard'
               end
        redirect_to(env, notice: 'User was successfully activated.')
      else
        redirect_to('https://app.recruitsuite.co', notice: 'User was successfully activated.')
      end
    else
      not_authenticated
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    # NOTE: name is allowed because one field exists on signup
    params.require(:user).permit(:name, :first_name, :last_name, :email, :password, :password_confirmation, :phone, :organization)
  end
end
