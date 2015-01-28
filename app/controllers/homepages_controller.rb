class HomepagesController < ApplicationController
  def index
  end

  def show
    @homepage = Homepage.find(params[:id])
    @homepage_editing = true

    gon.layout = @homepage.layout

    render 'frontend_homepage/show_homepage', layout: 'frontend'
  end

  def duplicate
  end
end
