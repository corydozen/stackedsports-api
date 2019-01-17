require "application_system_test_case"

class TempCommitOffersTest < ApplicationSystemTestCase
  setup do
    @temp_commit_offer = temp_commit_offers(:one)
  end

  test "visiting the index" do
    visit temp_commit_offers_url
    assert_selector "h1", text: "Temp Commit Offers"
  end

  test "creating a Temp commit offer" do
    visit temp_commit_offers_url
    click_on "New Temp Commit Offer"

    fill_in "Deleted", with: @temp_commit_offer.deleted
    fill_in "Grad Year", with: @temp_commit_offer.grad_year
    fill_in "High School", with: @temp_commit_offer.high_school
    fill_in "Position", with: @temp_commit_offer.position
    fill_in "Program Name", with: @temp_commit_offer.program_name
    fill_in "Recruit Name", with: @temp_commit_offer.recruit_name
    fill_in "State", with: @temp_commit_offer.state
    fill_in "Tweet Permalink", with: @temp_commit_offer.tweet_permalink
    fill_in "Tweet Text", with: @temp_commit_offer.tweet_text
    fill_in "Twitter Handle", with: @temp_commit_offer.twitter_handle
    click_on "Create Temp commit offer"

    assert_text "Temp commit offer was successfully created"
    click_on "Back"
  end

  test "updating a Temp commit offer" do
    visit temp_commit_offers_url
    click_on "Edit", match: :first

    fill_in "Deleted", with: @temp_commit_offer.deleted
    fill_in "Grad Year", with: @temp_commit_offer.grad_year
    fill_in "High School", with: @temp_commit_offer.high_school
    fill_in "Position", with: @temp_commit_offer.position
    fill_in "Program Name", with: @temp_commit_offer.program_name
    fill_in "Recruit Name", with: @temp_commit_offer.recruit_name
    fill_in "State", with: @temp_commit_offer.state
    fill_in "Tweet Permalink", with: @temp_commit_offer.tweet_permalink
    fill_in "Tweet Text", with: @temp_commit_offer.tweet_text
    fill_in "Twitter Handle", with: @temp_commit_offer.twitter_handle
    click_on "Update Temp commit offer"

    assert_text "Temp commit offer was successfully updated"
    click_on "Back"
  end

  test "destroying a Temp commit offer" do
    visit temp_commit_offers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Temp commit offer was successfully destroyed"
  end
end
