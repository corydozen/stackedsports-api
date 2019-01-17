require "application_system_test_case"

class CoEmailGroupingsTest < ApplicationSystemTestCase
  setup do
    @co_email_grouping = co_email_groupings(:one)
  end

  test "visiting the index" do
    visit co_email_groupings_url
    assert_selector "h1", text: "Co Email Groupings"
  end

  test "creating a Co email grouping" do
    visit co_email_groupings_url
    click_on "New Co Email Grouping"

    fill_in "Description", with: @co_email_grouping.description
    click_on "Create Co email grouping"

    assert_text "Co email grouping was successfully created"
    click_on "Back"
  end

  test "updating a Co email grouping" do
    visit co_email_groupings_url
    click_on "Edit", match: :first

    fill_in "Description", with: @co_email_grouping.description
    click_on "Update Co email grouping"

    assert_text "Co email grouping was successfully updated"
    click_on "Back"
  end

  test "destroying a Co email grouping" do
    visit co_email_groupings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Co email grouping was successfully destroyed"
  end
end
