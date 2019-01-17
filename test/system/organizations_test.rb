require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:one)
  end

  test "visiting the index" do
    visit organizations_url
    assert_selector "h1", text: "Organizations"
  end

  test "creating a Organization" do
    visit organizations_url
    click_on "New Organization"

    fill_in "Address", with: @organization.address
    fill_in "Address 2", with: @organization.address_2
    fill_in "City", with: @organization.city
    fill_in "Name", with: @organization.name
    fill_in "Phone", with: @organization.phone
    fill_in "State", with: @organization.state
    fill_in "Stripe Customer", with: @organization.stripe_customer_id
    fill_in "Zip", with: @organization.zip
    click_on "Create Organization"

    assert_text "Organization was successfully created"
    click_on "Back"
  end

  test "updating a Organization" do
    visit organizations_url
    click_on "Edit", match: :first

    fill_in "Address", with: @organization.address
    fill_in "Address 2", with: @organization.address_2
    fill_in "City", with: @organization.city
    fill_in "Name", with: @organization.name
    fill_in "Phone", with: @organization.phone
    fill_in "State", with: @organization.state
    fill_in "Stripe Customer", with: @organization.stripe_customer_id
    fill_in "Zip", with: @organization.zip
    click_on "Update Organization"

    assert_text "Organization was successfully updated"
    click_on "Back"
  end

  test "destroying a Organization" do
    visit organizations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Organization was successfully destroyed"
  end
end
