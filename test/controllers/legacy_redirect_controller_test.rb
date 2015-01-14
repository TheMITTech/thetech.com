require 'test_helper'

class LegacyRedirectControllerTest < ActionController::TestCase
  test "should get show_piece" do
    get :show_piece
    assert_response :success
  end

end
