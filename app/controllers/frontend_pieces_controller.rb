class FrontendPiecesController < FrontendController
  before_action only: [:show, :show_before_redirect] do
    set_cache_control_headers(1.hours)
  end

  # Metas and contents accessible in view:
  #
  # @article.meta(:sym)
  #   :headline, :subhead, :bytitle, :intro, :modified, :published_at
  #   :syndicated?, :authors, :authors_line
  #
  # @piece.meta(:sym)
  #   :tags, :primary_tag, :slug
  #
  # @html
  #

  def show_old_url
    piece = Piece.find_by(slug: params[:slug])
    if piece.nil?
      raise_404
    end
    redirect_to piece.frontend_display_path

  end

  def show_before_redirect
    piece = Piece.find_by(slug: params[:slug])

    if frontend_piece_path(year: params[:year], month: params[:month], day: params[:day], slug: params[:slug]) == piece.frontend_display_path
      show
    else
      redirect_to piece.frontend_display_path
    end
  end

  def show
    piece = Piece.find_by(slug: params[:slug])

    if piece.nil?
      raise_404
    else
      if piece.redirect?
        return redirect_to piece.redirect_url
      end

      if piece.article
        @version = piece.article.latest_published_version

        @article = Article.new
        @article.assign_attributes(@version.article_attributes)
        @title = piece.article.headline + " — " + piece.section.slug.titleize

        @piece = Piece.new
        @piece.assign_attributes(@version.piece_attributes)

        require 'renderer'
        renderer = Techplater::Renderer.new(@piece.web_template, @article.chunks)
        @html = renderer.render

        render 'show_article', layout: 'frontend'
      else
        @image = piece.image
        date = @image.created_at.strftime("%B %-d, %Y")
        @title = date + " — Photo"

        @piece = piece
        render 'show_image', layout: 'frontend'
      end
    end
  end

  def search
    @query = params[:query]

    if @query.present?
      @query = @query.gsub('+', ' ')

      query = Piece.search(@query)
      @pieces = query.page(params[:page]).per(20).records
      @count = query.results.total
    else
      @pieces = []
      @count = 0
    end

    @articles = @pieces.map(&:article).map(&:latest_published_version)

    @title = 'Search'

    render 'search', layout: 'frontend'
  end

  def image_search
    @query = params[:query]

    if @query.present?
      @query = @query.gsub('-', ' ')

      query = Image.search(@query)
      @images = query.page(params[:page]).per(20).records
      @count = query.results.total
    else
      @pieces = []
      @count = 0
    end

    render 'image_search', layout: 'frontend'
  end
end
