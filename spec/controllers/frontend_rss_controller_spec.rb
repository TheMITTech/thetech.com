require 'rails_helper'

RSpec.describe FrontendRssController, :type => :controller do

  describe "GET feed" do
    it "returns http success" do
      get :feed
      expect(response).to have_http_status(:success)
    end
  end

end
