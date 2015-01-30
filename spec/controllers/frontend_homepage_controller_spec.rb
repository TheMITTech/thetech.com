require_relative '../rails_helper'

describe FrontendHomepageController do
  describe "GET #show" do
    it "assigns the correct homepage to @homepage" do
      homepage = create(:homepage_published)
      get :show
      expect(assigns(:homepage)).to eq(homepage)
    end

    it "displays the homepage" do
      homepage = create(:homepage_published)
      get :show
      expect(response).to render_template :show_homepage
    end
  end
end

