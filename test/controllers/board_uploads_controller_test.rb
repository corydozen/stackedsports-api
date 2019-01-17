require 'test_helper'

class BoardUploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @board_upload = board_uploads(:one)
  end

  test "should get index" do
    get board_uploads_url
    assert_response :success
  end

  test "should get new" do
    get new_board_upload_url
    assert_response :success
  end

  test "should create board_upload" do
    assert_difference('BoardUpload.count') do
      post board_uploads_url, params: { board_upload: { board: @board_upload.board, delete_athletes: @board_upload.delete_athletes, delete_boards: @board_upload.delete_boards, processed: @board_upload.processed, requestor: @board_upload.requestor, user_id: @board_upload.user_id } }
    end

    assert_redirected_to board_upload_url(BoardUpload.last)
  end

  test "should show board_upload" do
    get board_upload_url(@board_upload)
    assert_response :success
  end

  test "should get edit" do
    get edit_board_upload_url(@board_upload)
    assert_response :success
  end

  test "should update board_upload" do
    patch board_upload_url(@board_upload), params: { board_upload: { board: @board_upload.board, delete_athletes: @board_upload.delete_athletes, delete_boards: @board_upload.delete_boards, processed: @board_upload.processed, requestor: @board_upload.requestor, user_id: @board_upload.user_id } }
    assert_redirected_to board_upload_url(@board_upload)
  end

  test "should destroy board_upload" do
    assert_difference('BoardUpload.count', -1) do
      delete board_upload_url(@board_upload)
    end

    assert_redirected_to board_uploads_url
  end
end
