class FrontendHomepageController < ApplicationController
  def show
    @homepage = Homepage.publish_ready.order('updated_at DESC').first
    render 'show_homepage', layout: 'frontend'
  end
end