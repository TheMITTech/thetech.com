require_relative '../rails_helper'

describe StaticPagesController do
  login_admin

  describe "GET #admin_homepage" do
    it "renders the admin homepage" do
      get :admin_homepage
      expect(response).to render_template :admin_homepage
    end
  end

end
