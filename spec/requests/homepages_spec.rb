require 'rails_helper'

RSpec.describe "Homepages", :type => :request do
  describe "GET /homepages" do
    it "works! (now write some real specs)" do
      get homepages_path
      expect(response).to have_http_status(200)
    end
  end
end
