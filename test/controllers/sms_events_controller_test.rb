require 'test_helper'

class SmsEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sms_event = sms_events(:one)
  end

  test "should get index" do
    get sms_events_url
    assert_response :success
  end

  test "should get new" do
    get new_sms_event_url
    assert_response :success
  end

  test "should create sms_event" do
    assert_difference('SmsEvent.count') do
      post sms_events_url, params: { sms_event: {  } }
    end

    assert_redirected_to sms_event_url(SmsEvent.last)
  end

  test "should show sms_event" do
    get sms_event_url(@sms_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_sms_event_url(@sms_event)
    assert_response :success
  end

  test "should update sms_event" do
    patch sms_event_url(@sms_event), params: { sms_event: {  } }
    assert_redirected_to sms_event_url(@sms_event)
  end

  test "should destroy sms_event" do
    assert_difference('SmsEvent.count', -1) do
      delete sms_event_url(@sms_event)
    end

    assert_redirected_to sms_events_url
  end
end
