require 'spec_helper'
include Warden::Test::Helpers

module RequestHelpers
  def sign_in_as_user!
    before(:each) do
      user = FactoryGirl.create(:user)
      login_as user, scope: :user
    end
  end

  def sign_in_as_admin!
    before(:each) do
      user = FactoryGirl.create(:admin)
      login_as user, scope: :user
    end
  end

  def signin(user)
    login_as user, scope: :user
  end
end