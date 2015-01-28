require "rails_helper"

RSpec.describe HomepagesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/homepages").to route_to("homepages#index")
    end

    it "routes to #new" do
      expect(:get => "/homepages/new").to route_to("homepages#new")
    end

    it "routes to #show" do
      expect(:get => "/homepages/1").to route_to("homepages#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/homepages/1/edit").to route_to("homepages#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/homepages").to route_to("homepages#create")
    end

    it "routes to #update" do
      expect(:put => "/homepages/1").to route_to("homepages#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/homepages/1").to route_to("homepages#destroy", :id => "1")
    end

  end
end
