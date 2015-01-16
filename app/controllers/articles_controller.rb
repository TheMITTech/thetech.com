class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :assets_list]
  before_action :prepare_authors_json, only: [:new, :edit]

  load_and_authorize_resource

  respond_to :html

  def index
    # Rough query syntax:
    #
    # If query looks like "  v343 N9394    " or "V134/N61" or "v100n1"
    #   then the articles from that issue are returned.
    # Otherwise
    #   articles are searched for matching headline or other metadata.

    match = /^\s*V(\d+)[ \/]?N(\d+)\s*$/i.match(params[:q])
    unless match.nil?
      issue = Issue.find_by(volume: match[1].to_i, number: match[2].to_i)
      @articles = issue.articles rescue []
    else
      @articles = Article.search_query(params[:q]).order('created_at DESC').limit(100)
    end

    @json_articles = @articles.map(&:as_display_json)

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
    @article.assign_attributes(article_params)
    @piece.assign_attributes(piece_params)

    if @article.valid? && @piece.valid?
      @piece.save
      @article.save

      redirect_to article_article_version_path(@article, save_version)
    else
      @flash[:error] = (@article.errors.full_messages + @piece.errors.full_messages).join("\n")
      render 'edit'
    end
  end

  def destroy
    @article.piece.destroy
    @article.destroy
    @article.article_versions.destroy_all
    respond_with(@article)
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
      params.permit(:section_id, :primary_tag, :tags_string, :issue_id, :syndicated, :slug)
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
        },
        user_id: @current_user.id
      )

      version.draft!

      version
    end
end
