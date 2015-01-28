require 'rails_helper'

RSpec.describe "ArticleLists", :type => :request do
  sign_in_as_admin!

  describe "GET /article_lists" do
    it "works! (now write some real specs)" do
      get article_lists_path
      expect(response).to have_http_status(200)
    end
  end
end
