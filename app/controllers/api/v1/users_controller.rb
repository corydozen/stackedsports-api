class Api::V1::UsersController < Api::ApiController
  skip_before_action :require_login, only: %i[new create activate]
  before_action :set_user, only: %i[show edit update destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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

        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: api_user_url(@user)}
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    respond_to do |format|
      if @user = User.load_from_activation_token(params[:id])

        @user.activate!
        @user.add_role :activated
        format.html { redirect_to('https://app.recruitsuite.co', notice: 'User was successfully activated.') }
        format.json { render 'api/v1/users/show', status: :ok }

      else
        not_authenticated
      end
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
    params.require(:user).permit(:name, :first_name, :last_name, :email, :password, :password_confirmation, :phone)
  end
end
