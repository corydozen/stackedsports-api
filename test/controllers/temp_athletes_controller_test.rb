require 'test_helper'

class TempAthletesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @temp_athlete = temp_athletes(:one)
  end

  test "should get index" do
    get temp_athletes_url
    assert_response :success
  end

  test "should get new" do
    get new_temp_athlete_url
    assert_response :success
  end

  test "should create temp_athlete" do
    assert_difference('TempAthlete.count') do
      post temp_athletes_url, params: { temp_athlete: {  } }
    end

    assert_redirected_to temp_athlete_url(TempAthlete.last)
  end

  test "should show temp_athlete" do
    get temp_athlete_url(@temp_athlete)
    assert_response :success
  end

  test "should get edit" do
    get edit_temp_athlete_url(@temp_athlete)
    assert_response :success
  end

  test "should update temp_athlete" do
    patch temp_athlete_url(@temp_athlete), params: { temp_athlete: {  } }
    assert_redirected_to temp_athlete_url(@temp_athlete)
  end

  test "should destroy temp_athlete" do
    assert_difference('TempAthlete.count', -1) do
      delete temp_athlete_url(@temp_athlete)
    end

    assert_redirected_to temp_athletes_url
  end
end
