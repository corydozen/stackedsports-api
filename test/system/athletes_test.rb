require "application_system_test_case"

class AthletesTest < ApplicationSystemTestCase
  setup do
    @athlete = athletes(:one)
  end

  test "visiting the index" do
    visit athletes_url
    assert_selector "h1", text: "Athletes"
  end

  test "creating a Athlete" do
    visit athletes_url
    click_on "New Athlete"

    fill_in "Arms", with: @athlete.arms_id
    fill_in "Coach Name", with: @athlete.coach_name
    fill_in "Email", with: @athlete.email
    fill_in "Fathers Name", with: @athlete.fathers_name
    fill_in "First Name", with: @athlete.first_name
    fill_in "Graduation Year", with: @athlete.graduation_year
    fill_in "High School", with: @athlete.high_school
    fill_in "Hudl", with: @athlete.hudl_id
    fill_in "Instagram", with: @athlete.instagram_id
    fill_in "Last Name", with: @athlete.last_name
    fill_in "Mothers Name", with: @athlete.mothers_name
    fill_in "Nick Name", with: @athlete.nick_name
    fill_in "Phone", with: @athlete.phone
    fill_in "State", with: @athlete.state
    fill_in "Team", with: @athlete.team_id
    fill_in "Twitter Profile", with: @athlete.twitter_profile_id
    click_on "Create Athlete"

    assert_text "Athlete was successfully created"
    click_on "Back"
  end

  test "updating a Athlete" do
    visit athletes_url
    click_on "Edit", match: :first

    fill_in "Arms", with: @athlete.arms_id
    fill_in "Coach Name", with: @athlete.coach_name
    fill_in "Email", with: @athlete.email
    fill_in "Fathers Name", with: @athlete.fathers_name
    fill_in "First Name", with: @athlete.first_name
    fill_in "Graduation Year", with: @athlete.graduation_year
    fill_in "High School", with: @athlete.high_school
    fill_in "Hudl", with: @athlete.hudl_id
    fill_in "Instagram", with: @athlete.instagram_id
    fill_in "Last Name", with: @athlete.last_name
    fill_in "Mothers Name", with: @athlete.mothers_name
    fill_in "Nick Name", with: @athlete.nick_name
    fill_in "Phone", with: @athlete.phone
    fill_in "State", with: @athlete.state
    fill_in "Team", with: @athlete.team_id
    fill_in "Twitter Profile", with: @athlete.twitter_profile_id
    click_on "Update Athlete"

    assert_text "Athlete was successfully updated"
    click_on "Back"
  end

  test "destroying a Athlete" do
    visit athletes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Athlete was successfully destroyed"
  end
end
