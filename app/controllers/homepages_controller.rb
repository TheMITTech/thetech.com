class HomepagesController < ApplicationController
  def index
  end

  def show
    @homepage = Homepage.find(params[:id])
    @homepage_editing = true

    gon.layout = @homepage.layout

    render 'frontend_homepage/show_homepage', layout: 'frontend'
  end

  def update
    @homepage = Homepage.find(params[:id])
    @homepage.update(layout: JSON.parse(params[:layout]))

    redirect_to homepage_path(@homepage), flash: {success: 'Successfully updated homepage. '}
  end

  def mark_publish_ready
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

    m = {uuid: @uuid, type: @type}

    case @type.to_sym
    when :article
      piece = Piece.find(params[:piece_id])
      m[:piece] = params[:piece_id]
      m[:headline] = piece.try(:article).try(:headline).try(:presence) || 'Empty headline'
      m[:lede] = piece.try(:article).try(:lede).try(:presence) || 'Empty lede'
    when :img, :img_nocaption
      picture = Picture.find(params[:picture_id])
      m[:picture] = params[:picture_id]
      m[:caption] = picture.try(:image).try(:caption).try(:presence) || 'Empty caption'
    when :links
      m[:links] = params[:links].select(&:present?)
    end

    @homepage_editing = true
    @content = render_to_string(partial: 'modules/submodule.html.erb', locals: {m: m})
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
    @content = render_to_string(partial: 'homepages/row', locals: {row: row})
    @json = row.to_json

    respond_to do |f|
      f.js
    end
  end
end
