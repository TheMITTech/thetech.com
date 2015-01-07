require 'test_helper'

class HomepageControllerTest < ActionController::TestCase
  test "should get homepage" do
    get :homepage
    assert_response :success
  end

end
