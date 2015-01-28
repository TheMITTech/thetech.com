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

  def new_specific_submodule_form
    @uuid = params[:uuid]
    @type = params[:type]

    respond_to do |f|
      f.js
    end
  end

  def create_specific_submodule
    @type = params[:type]
    @uuid = params[:uuid]

    m = {uuid: @uuid, type: @type}

    case @type.to_sym
    when :article
      m[:piece] = params[:piece_id]
      @content = render_to_string(partial: 'modules/submodule.html.erb', locals: {m: m})
    end

    @json = m.to_json

    respond_to do |f|
      f.js
    end
  end
end
