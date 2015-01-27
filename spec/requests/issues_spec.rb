require 'rails_helper'

RSpec.describe "Issues", :type => :request do
  sign_in_as_admin!

  describe "GET /admin/issues" do
    it "should list the issues" do
      get issues_path
      expect(response).to have_http_status(200)
    end
  end
end
