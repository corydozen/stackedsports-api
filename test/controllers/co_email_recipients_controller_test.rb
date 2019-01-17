require 'test_helper'

class CoEmailRecipientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @co_email_recipient = co_email_recipients(:one)
  end

  test "should get index" do
    get co_email_recipients_url
    assert_response :success
  end

  test "should get new" do
    get new_co_email_recipient_url
    assert_response :success
  end

  test "should create co_email_recipient" do
    assert_difference('CoEmailRecipient.count') do
      post co_email_recipients_url, params: { co_email_recipient: { email: @co_email_recipient.email, enabled: @co_email_recipient.enabled, full_name: @co_email_recipient.full_name } }
    end

    assert_redirected_to co_email_recipient_url(CoEmailRecipient.last)
  end

  test "should show co_email_recipient" do
    get co_email_recipient_url(@co_email_recipient)
    assert_response :success
  end

  test "should get edit" do
    get edit_co_email_recipient_url(@co_email_recipient)
    assert_response :success
  end

  test "should update co_email_recipient" do
    patch co_email_recipient_url(@co_email_recipient), params: { co_email_recipient: { email: @co_email_recipient.email, enabled: @co_email_recipient.enabled, full_name: @co_email_recipient.full_name } }
    assert_redirected_to co_email_recipient_url(@co_email_recipient)
  end

  test "should destroy co_email_recipient" do
    assert_difference('CoEmailRecipient.count', -1) do
      delete co_email_recipient_url(@co_email_recipient)
    end

    assert_redirected_to co_email_recipients_url
  end
end
