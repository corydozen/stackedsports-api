require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  setup do
    @team = teams(:one)
  end

  test "visiting the index" do
    visit teams_url
    assert_selector "h1", text: "Teams"
  end

  test "creating a Team" do
    visit teams_url
    click_on "New Team"

    fill_in "Name", with: @team.name
    fill_in "Organization", with: @team.organization_id
    fill_in "Override Plan", with: @team.override_plan_id
    fill_in "Phone", with: @team.phone
    fill_in "Photo Url", with: @team.photo_url
    fill_in "Stripe Subscription", with: @team.stripe_subscription_id
    fill_in "Trial Start Date", with: @team.trial_start_date
    click_on "Create Team"

    assert_text "Team was successfully created"
    click_on "Back"
  end

  test "updating a Team" do
    visit teams_url
    click_on "Edit", match: :first

    fill_in "Name", with: @team.name
    fill_in "Organization", with: @team.organization_id
    fill_in "Override Plan", with: @team.override_plan_id
    fill_in "Phone", with: @team.phone
    fill_in "Photo Url", with: @team.photo_url
    fill_in "Stripe Subscription", with: @team.stripe_subscription_id
    fill_in "Trial Start Date", with: @team.trial_start_date
    click_on "Update Team"

    assert_text "Team was successfully updated"
    click_on "Back"
  end

  test "destroying a Team" do
    visit teams_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Team was successfully destroyed"
  end
end
