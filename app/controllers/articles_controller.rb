class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :incopy_tagged_file, :assets_list, :versions]
  before_action :prepare_authors_json, only: [:new, :edit]

  respond_to :html

  def index
    @articles = Article.search_query(params[:q]).order('created_at DESC').limit(100)

    @json_articles = @articles.map do |a|
      {
        slug: a.piece.friendly_id,
        section_name: a.piece.section.name,
        headline: a.headline,
        subhead: a.subhead,
        authors_line: a.authors_line,
        bytitle: a.bytitle,
        path: article_path(a),
        edit_path: edit_article_path(a)
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
    respond_with(@article)
  end

  def incopy_tagged_file
    require 'tempfile'

    file = Tempfile.new('incopy_tagged_file', encoding: 'UTF-16LE')
    file.write(@article.incopy_tagged_text)
    file.close

    send_file file.path, filename: "#{@article.headline}.txt"
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
