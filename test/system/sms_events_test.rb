require "application_system_test_case"

class SmsEventsTest < ApplicationSystemTestCase
  setup do
    @sms_event = sms_events(:one)
  end

  test "visiting the index" do
    visit sms_events_url
    assert_selector "h1", text: "Sms Events"
  end

  test "creating a Sms event" do
    visit sms_events_url
    click_on "New Sms Event"

    click_on "Create Sms event"

    assert_text "Sms event was successfully created"
    click_on "Back"
  end

  test "updating a Sms event" do
    visit sms_events_url
    click_on "Edit", match: :first

    click_on "Update Sms event"

    assert_text "Sms event was successfully updated"
    click_on "Back"
  end

  test "destroying a Sms event" do
    visit sms_events_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Sms event was successfully destroyed"
  end
end
