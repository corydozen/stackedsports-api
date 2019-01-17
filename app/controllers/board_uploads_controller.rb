class BoardUploadsController < ApplicationController
  before_action :set_board_upload, only: [:show, :edit, :update, :destroy]

  # GET /board_uploads
  # GET /board_uploads.json
  def index
    @rs_users = RsUser.has_twitter_account
    @board_upload = BoardUpload.new

    per_page = params[:per_page] || 10
    @board_uploads = BoardUpload.search(params[:search]).paginate( page: params[:page], per_page: per_page).order(id: :desc)
  end

  # GET /board_uploads/1
  # GET /board_uploads/1.json
  def show
  end

  # GET /board_uploads/new
  def new
    @rs_users = RsUser.has_twitter_account
    @board_upload = BoardUpload.new
  end

  # GET /board_uploads/1/edit
  def edit
    @rs_users = RsUser.has_twitter_account
  end

  # POST /board_uploads
  # POST /board_uploads.json
  def create
    @board_upload = BoardUpload.new(board_upload_params)
    @rs_users = RsUser.has_twitter_account
    respond_to do |format|
      if @board_upload.save
        # UploadBoardToRSJob.perform_later(@board_upload)
        format.html { redirect_to board_uploads_path, notice: 'Board upload was successfully created.' }
        format.json { render :show, status: :created, location: @board_upload }
      else
        format.html { render :new }
        format.json { render json: @board_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /board_uploads/1
  # PATCH/PUT /board_uploads/1.json
  def update
    respond_to do |format|
      if @board_upload.update(board_upload_params)
        format.html { redirect_to board_uploads_path, notice: 'Board upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @board_upload }
      else
        format.html { render :edit }
        format.json { render json: @board_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /board_uploads/1
  # DELETE /board_uploads/1.json
  def destroy
    @board_upload.destroy
    respond_to do |format|
      format.html { redirect_to board_uploads_url, notice: 'Board upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_board_upload
      @board_upload = BoardUpload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def board_upload_params
      params.require(:board_upload).permit(:user_id, :board, :delete_boards, :delete_athletes, :requestor, :processed)
    end

    def prepare_board_import
      @rs_users = RsUser.all
      render template: 'rs/import_board'
    end

    def import_board
      @user = RsUser.find(params[:user])
      if @user.present? && @user.twitterAccount.present?
        p @user.twitterAccount[:oauthToken]
        p @user.twitterAccount[:oauthTokenSecret]
      end

      # NOTE: Need to upload file to S3 for storage.


      redirect_to import_board_path, success: 'Upload was successful.'
    end

    def delete_all_boards
      # rs_team = RsTeam.find_by(_wperm: rs_user._id)
      # @boards = RsBoard.where(_p_team: "Team$#{rs_team._id}")
    end

    def delete_all_athletes

    end
end
