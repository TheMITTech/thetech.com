class FrontendHomepageController < ApplicationController
  def show
    @homepage = Homepage.publish_ready.last
    render 'show_homepage', layout: 'frontend'
  end
end