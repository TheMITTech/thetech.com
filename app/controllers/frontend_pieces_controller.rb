class FrontendPiecesController < FrontendController
  before_action :set_cache_control_headers, only: [:show]

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
  def show
    piece = Piece.find(params[:id])

    if params[:section_name] != piece.meta(:section_name).downcase.gsub(/ /, '-')
      raise_404
    else
      if piece.article
        @version = piece.article.latest_published_version

        @article = Article.new
        @article.assign_attributes(@version.article_attributes)

        @piece = Piece.new
        @piece.assign_attributes(@version.piece_attributes)

        require 'renderer'
        renderer = Techplater::Renderer.new(@piece.web_template, @article.chunks)
        @html = renderer.render

        render 'show_article', layout: 'frontend'
      else
        @image = piece.image
        @title = 'Graphic: ' + @image.pictures.first.content_file_name

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
