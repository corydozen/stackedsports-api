require 'test_helper'

class CoEmailGroupingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @co_email_grouping = co_email_groupings(:one)
  end

  test "should get index" do
    get co_email_groupings_url
    assert_response :success
  end

  test "should get new" do
    get new_co_email_grouping_url
    assert_response :success
  end

  test "should create co_email_grouping" do
    assert_difference('CoEmailGrouping.count') do
      post co_email_groupings_url, params: { co_email_grouping: { description: @co_email_grouping.description } }
    end

    assert_redirected_to co_email_grouping_url(CoEmailGrouping.last)
  end

  test "should show co_email_grouping" do
    get co_email_grouping_url(@co_email_grouping)
    assert_response :success
  end

  test "should get edit" do
    get edit_co_email_grouping_url(@co_email_grouping)
    assert_response :success
  end

  test "should update co_email_grouping" do
    patch co_email_grouping_url(@co_email_grouping), params: { co_email_grouping: { description: @co_email_grouping.description } }
    assert_redirected_to co_email_grouping_url(@co_email_grouping)
  end

  test "should destroy co_email_grouping" do
    assert_difference('CoEmailGrouping.count', -1) do
      delete co_email_grouping_url(@co_email_grouping)
    end

    assert_redirected_to co_email_groupings_url
  end
end
