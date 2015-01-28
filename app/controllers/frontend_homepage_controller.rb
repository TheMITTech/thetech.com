class FrontendHomepageController < ApplicationController
  def show
    @homepage = Homepage.last
    render 'show_homepage', layout: 'frontend'
  end
end