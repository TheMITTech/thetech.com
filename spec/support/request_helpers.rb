require 'spec_helper'
include Warden::Test::Helpers

module RequestHelpers
  def sign_in_as_user!
    user = FactoryGirl.create(:user)
    signin(user)
    user
  end

  def sign_in_as_admin!
    user = FactoryGirl.create(:admin)
    signin(user)
    user
  end

  def signin(user)
    login_as user, scope: :user
  end
end