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

  def new_submodule_form
    @uuid = params[:module_uuid]

    respond_to do |f|
      f.js
    end
  end
end
