require "application_system_test_case"

class TempAthletesTest < ApplicationSystemTestCase
  setup do
    @temp_athlete = temp_athletes(:one)
  end

  test "visiting the index" do
    visit temp_athletes_url
    assert_selector "h1", text: "Temp Athletes"
  end

  test "creating a Temp athlete" do
    visit temp_athletes_url
    click_on "New Temp Athlete"

    click_on "Create Temp athlete"

    assert_text "Temp athlete was successfully created"
    click_on "Back"
  end

  test "updating a Temp athlete" do
    visit temp_athletes_url
    click_on "Edit", match: :first

    click_on "Update Temp athlete"

    assert_text "Temp athlete was successfully updated"
    click_on "Back"
  end

  test "destroying a Temp athlete" do
    visit temp_athletes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Temp athlete was successfully destroyed"
  end
end
