class FrontendHomepageController < ApplicationController
  def show
    @homepage = Homepage.published
    render 'show_homepage', layout: 'frontend'
  end

  private
    def allowed_in_frontend?
      true
    end
end
