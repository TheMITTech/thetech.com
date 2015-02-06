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
    piece = Piece.find_by!(slug: params[:slug])

    datetime = piece.publish_datetime

    if params[:year].to_d != datetime.year ||
       params[:month].to_d != datetime.month ||
       params[:day].to_d != datetime.day
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
      end
    end
  end

  def search
    @query = params[:query].gsub('+', ' ')

    if @query.present?
      @pieces = Piece.search_query(@query).page(params[:page]).per(20)
    else
      @pieces = []
    end

    @articles = @pieces.map(&:article)

    render 'search', layout: 'frontend'
  end
end
