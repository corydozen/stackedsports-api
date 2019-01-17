require "application_system_test_case"

class CoEmailRecipientsTest < ApplicationSystemTestCase
  setup do
    @co_email_recipient = co_email_recipients(:one)
  end

  test "visiting the index" do
    visit co_email_recipients_url
    assert_selector "h1", text: "Co Email Recipients"
  end

  test "creating a Co email recipient" do
    visit co_email_recipients_url
    click_on "New Co Email Recipient"

    fill_in "Email", with: @co_email_recipient.email
    fill_in "Enabled", with: @co_email_recipient.enabled
    fill_in "Full Name", with: @co_email_recipient.full_name
    click_on "Create Co email recipient"

    assert_text "Co email recipient was successfully created"
    click_on "Back"
  end

  test "updating a Co email recipient" do
    visit co_email_recipients_url
    click_on "Edit", match: :first

    fill_in "Email", with: @co_email_recipient.email
    fill_in "Enabled", with: @co_email_recipient.enabled
    fill_in "Full Name", with: @co_email_recipient.full_name
    click_on "Update Co email recipient"

    assert_text "Co email recipient was successfully updated"
    click_on "Back"
  end

  test "destroying a Co email recipient" do
    visit co_email_recipients_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Co email recipient was successfully destroyed"
  end
end
