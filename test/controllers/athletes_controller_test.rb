require 'test_helper'

class AthletesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @athlete = athletes(:one)
  end

  test "should get index" do
    get athletes_url
    assert_response :success
  end

  test "should get new" do
    get new_athlete_url
    assert_response :success
  end

  test "should create athlete" do
    assert_difference('Athlete.count') do
      post athletes_url, params: { athlete: { arms_id: @athlete.arms_id, coach_name: @athlete.coach_name, email: @athlete.email, fathers_name: @athlete.fathers_name, first_name: @athlete.first_name, graduation_year: @athlete.graduation_year, high_school: @athlete.high_school, hudl_id: @athlete.hudl_id, instagram_id: @athlete.instagram_id, last_name: @athlete.last_name, mothers_name: @athlete.mothers_name, nick_name: @athlete.nick_name, phone: @athlete.phone, state: @athlete.state, team_id: @athlete.team_id, twitter_profile_id: @athlete.twitter_profile_id } }
    end

    assert_redirected_to athlete_url(Athlete.last)
  end

  test "should show athlete" do
    get athlete_url(@athlete)
    assert_response :success
  end

  test "should get edit" do
    get edit_athlete_url(@athlete)
    assert_response :success
  end

  test "should update athlete" do
    patch athlete_url(@athlete), params: { athlete: { arms_id: @athlete.arms_id, coach_name: @athlete.coach_name, email: @athlete.email, fathers_name: @athlete.fathers_name, first_name: @athlete.first_name, graduation_year: @athlete.graduation_year, high_school: @athlete.high_school, hudl_id: @athlete.hudl_id, instagram_id: @athlete.instagram_id, last_name: @athlete.last_name, mothers_name: @athlete.mothers_name, nick_name: @athlete.nick_name, phone: @athlete.phone, state: @athlete.state, team_id: @athlete.team_id, twitter_profile_id: @athlete.twitter_profile_id } }
    assert_redirected_to athlete_url(@athlete)
  end

  test "should destroy athlete" do
    assert_difference('Athlete.count', -1) do
      delete athlete_url(@athlete)
    end

    assert_redirected_to athletes_url
  end
end
