class HomepagesController < ApplicationController
  before_action :set_homepage, except: [:index, :new_submodule_form, :new_row_form, :new_specific_submodule_form, :create_specific_submodule, :create_new_row]

  load_and_authorize_resource only: [:index, :show, :update, :duplicate, :publish]

  def index
    @homepages = Homepage.order('created_at DESC').limit(100)
  end

  def show
    @homepage = Homepage.find(params[:id])
    @latest_issue = Issue.latest_published

    if @homepage.published? || @homepage.publish_ready?
      @homepage_warning = "Layout locked since it has already been marked ready for publication."
      @homepage_locked = true
    else
      @homepage_editing = true
    end

    gon.layout = @homepage.layout

    render 'frontend/homepage', layout: 'frontend'
  end

  def update
    @homepage = Homepage.find(params[:id])
    @homepage.update(
      layout: JSON.parse(params[:layout]),
      status: params[:status]
    )

    redirect_to homepage_path(@homepage), flash: {success: 'Successfully updated homepage. '}
  end

  def mark_publish_ready
    authorize! :ready, @homepage

    @homepage = Homepage.find(params[:id])
    @homepage.publish_ready!

    redirect_to homepage_path(@homepage), flash: {success: 'Successfully marked layout as publish ready. '}
  end

  def duplicate
    @homepage = Homepage.find(params[:id])

    nh = Homepage.create(layout: @homepage.layout)

    redirect_to homepage_path(nh), flash: {success: 'Successfully duplicated the layout. '}
  end

  def new_submodule_form
    @uuid = params[:module_uuid]

    respond_to do |f|
      f.js
    end
  end

  def new_row_form
    respond_to do |f|
      f.js
    end
  end

  def new_specific_submodule_form
    @uuid = params[:uuid]
    @mod_uuid = params[:mod_uuid]
    @type = params[:type]

    respond_to do |f|
      f.js
    end
  end

  def create_specific_submodule
    @type = params[:type]
    @uuid = params[:uuid]
    @mod_uuid = params[:mod_uuid]

    sub_params = params[:submodule]

    m = {uuid: @uuid, type: @type}

    case @type.to_sym
    when :article
      m[:article_id] = sub_params[:article_id]
    when :img, :img_nocaption
      m[:image_id] = sub_params[:image_id]
    end

    @homepage_editing = true
    @content = render_to_string(partial: 'frontend/homepage/modules/submodule', locals: {m: m})
    @json = m.to_json

    respond_to do |f|
      f.js
    end
  end

  def create_new_row
    @uuid = params[:uuid]
    @type = params[:type].split(',').map(&:to_i)

    row = {
      uuid: @uuid,
      modules: @type.map do |c|
        {
          uuid: Homepage.generate_uuid,
          cols: c,
          submodules: []
        }
      end
    }

    @homepage_editing = true
    @content = render_to_string(partial: 'frontend/homepage/row', locals: {row: row})
    @json = row.to_json

    respond_to do |f|
      f.js
    end
  end

  def publish
    require 'varnish/purger'

    @homepage.published!
    Varnish::Purger.purge(root_path, true)

    redirect_to publishing_dashboard_path, flash: {success: "You have successfully published the homepage layout. "}
  end

  private
    def set_homepage
      @homepage = Homepage.find(params[:id])
    end
end
