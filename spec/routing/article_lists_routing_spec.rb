require "rails_helper"

RSpec.describe ArticleListsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/article_lists").to route_to("article_lists#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/article_lists/new").to route_to("article_lists#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/article_lists/1").to route_to("article_lists#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/article_lists").to route_to("article_lists#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin/article_lists/1").to route_to("article_lists#destroy", :id => "1")
    end

  end
end
