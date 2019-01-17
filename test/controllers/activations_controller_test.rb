require 'test_helper'

class ActivationsControllerTest < ActionDispatch::IntegrationTest
  test "should get activate" do
    get activations_activate_url
    assert_response :success
  end

end
