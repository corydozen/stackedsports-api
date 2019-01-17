require "application_system_test_case"

class BoardUploadsTest < ApplicationSystemTestCase
  setup do
    @board_upload = board_uploads(:one)
  end

  test "visiting the index" do
    visit board_uploads_url
    assert_selector "h1", text: "Board Uploads"
  end

  test "creating a Board upload" do
    visit board_uploads_url
    click_on "New Board Upload"

    fill_in "Board", with: @board_upload.board
    fill_in "Delete Athletes", with: @board_upload.delete_athletes
    fill_in "Delete Boards", with: @board_upload.delete_boards
    fill_in "Processed", with: @board_upload.processed
    fill_in "Requestor", with: @board_upload.requestor
    fill_in "User", with: @board_upload.user_id
    click_on "Create Board upload"

    assert_text "Board upload was successfully created"
    click_on "Back"
  end

  test "updating a Board upload" do
    visit board_uploads_url
    click_on "Edit", match: :first

    fill_in "Board", with: @board_upload.board
    fill_in "Delete Athletes", with: @board_upload.delete_athletes
    fill_in "Delete Boards", with: @board_upload.delete_boards
    fill_in "Processed", with: @board_upload.processed
    fill_in "Requestor", with: @board_upload.requestor
    fill_in "User", with: @board_upload.user_id
    click_on "Update Board upload"

    assert_text "Board upload was successfully updated"
    click_on "Back"
  end

  test "destroying a Board upload" do
    visit board_uploads_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Board upload was successfully destroyed"
  end
end
