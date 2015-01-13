class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :as_xml, :assets_list]
  before_action :prepare_authors_json, only: [:new, :edit]

  load_and_authorize_resource

  respond_to :html

  def index
    @articles = Article.search_query(params[:q]).order('created_at DESC').limit(100)

    @json_articles = @articles.map do |a|
      {
        slug: a.piece.friendly_id,
        publish_status: a.published? ? '✓' : '',
        draft_pending: a.has_pending_draft? ? '✓' : '',
        section_name: a.piece.section.name,
        headline: a.headline,
        subhead: a.subhead,
        authors_line: a.authors_line,
        bytitle: a.bytitle,
        published_version_path: a.display_version && article_article_version_path(a, a.display_version),
        draft_version_path: a.pending_draft && article_article_version_path(a, a.pending_draft),
        latest_version_path: article_article_version_path(a, a.latest_version),
        versions_path: article_article_versions_path(a)
      }
    end

    gon.articles = @json_articles

    respond_to do |format|
      format.html
      format.json { render json: @json_articles }
    end
  end

  def new
    @article = Article.new
    @piece = Piece.new
    respond_with(@article)
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    @piece = Piece.new(piece_params)

    if @article.valid? && @piece.valid?
      @article.piece = @piece
      @article.save

      redirect_to article_article_version_path(@article, save_version)
    else
      @flash[:error] = (@article.errors.full_messages + @piece.errors.full_messages).join("\n")
      render 'new'
    end
  end

  def update
    if @article.update(article_params)
      @article.piece.update(piece_params)

      redirect_to article_article_version_path(@article, save_version)
    else
      @flash[:error] = @article.errors.full_messages.join("\n")
      render 'edit'
    end
  end

  def destroy
    @article.piece.destroy
    @article.destroy
    @article.article_versions.destroy_all
    respond_with(@article)
  end

  def as_xml
    headers["Content-Type"] = 'text/plain; charset=UTF-8'
    render text: @article.as_xml.html_safe
  end

  def assets_list
  end

  private
    def set_article
      @article = Article.find(params[:id])
      @piece = @article.piece
    end

    def article_params
      params.require(:article).permit(:headline, :subhead, :bytitle, :html, :section_id, :author_ids, :lede)
    end

    def piece_params
      params.permit(:section_id, :primary_tag, :tags_string, :issue_id, :syndicated)
    end

    def prepare_authors_json
      gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
      gon.prefilled_authors = @article.authors.map { |a| {id: a.id, name: a.name} } rescue []
    end

    def save_version
      version = ArticleVersion.create(
        article_id: @article.id,
        contents: {
          article_params: article_params,
          piece_params: piece_params,
          article_attributes: @article.attributes,
          piece_attributes: @piece.attributes
        }
      )

      version.draft!

      version
    end
end
