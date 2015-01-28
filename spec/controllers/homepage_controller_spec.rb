require_relative '../rails_helper'

describe HomepageController do
  describe "GET #homepage" do
    it "displays the homepage" do
      get :homepage
      expect(response).to render_template :homepage
    end
  end
end

