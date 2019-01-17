require 'test_helper'

class TempCommitOffersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @temp_commit_offer = temp_commit_offers(:one)
  end

  test "should get index" do
    get temp_commit_offers_url
    assert_response :success
  end

  test "should get new" do
    get new_temp_commit_offer_url
    assert_response :success
  end

  test "should create temp_commit_offer" do
    assert_difference('TempCommitOffer.count') do
      post temp_commit_offers_url, params: { temp_commit_offer: { deleted: @temp_commit_offer.deleted, grad_year: @temp_commit_offer.grad_year, high_school: @temp_commit_offer.high_school, position: @temp_commit_offer.position, program_name: @temp_commit_offer.program_name, recruit_name: @temp_commit_offer.recruit_name, state: @temp_commit_offer.state, tweet_permalink: @temp_commit_offer.tweet_permalink, tweet_text: @temp_commit_offer.tweet_text, twitter_handle: @temp_commit_offer.twitter_handle } }
    end

    assert_redirected_to temp_commit_offer_url(TempCommitOffer.last)
  end

  test "should show temp_commit_offer" do
    get temp_commit_offer_url(@temp_commit_offer)
    assert_response :success
  end

  test "should get edit" do
    get edit_temp_commit_offer_url(@temp_commit_offer)
    assert_response :success
  end

  test "should update temp_commit_offer" do
    patch temp_commit_offer_url(@temp_commit_offer), params: { temp_commit_offer: { deleted: @temp_commit_offer.deleted, grad_year: @temp_commit_offer.grad_year, high_school: @temp_commit_offer.high_school, position: @temp_commit_offer.position, program_name: @temp_commit_offer.program_name, recruit_name: @temp_commit_offer.recruit_name, state: @temp_commit_offer.state, tweet_permalink: @temp_commit_offer.tweet_permalink, tweet_text: @temp_commit_offer.tweet_text, twitter_handle: @temp_commit_offer.twitter_handle } }
    assert_redirected_to temp_commit_offer_url(@temp_commit_offer)
  end

  test "should destroy temp_commit_offer" do
    assert_difference('TempCommitOffer.count', -1) do
      delete temp_commit_offer_url(@temp_commit_offer)
    end

    assert_redirected_to temp_commit_offers_url
  end
end
