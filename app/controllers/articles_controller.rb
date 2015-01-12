class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :incopy_tagged_file, :assets_list]
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

  def show
    require 'renderer'
    @title = @article.headline
    renderer = Techplater::Renderer.new(@article.piece.web_template, @article.chunks)
    @html = renderer.render

    render 'show', layout: 'bare'
  end

  def new
    @article = Article.new
    respond_with(@article)
  end

  def edit
  end

  def create
    @article = Article.new(article_params)

    if @article.valid?
      @article.piece = Piece.new(
        section_id: params[:section_id],
        issue_id: params[:issue_id],
        syndicated: params[:syndicated]
      )
      @article.piece.tag_list = params[:tag_list]
      @article.save

      redirect_to article_path(@article)
    else
      @flash[:error] = @article.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def update
    if @article.update(article_params)
      @article.piece.update(
        section_id: params[:section_id],
        tag_list: params[:tag_list],
        issue_id: params[:issue_id],
        syndicated: params[:syndicated]
      )

      respond_with(@article)
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
    end

    def article_params
      params.require(:article).permit(:headline, :subhead, :bytitle, :html, :section_id, :author_ids)
    end

    def prepare_authors_json
      gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
      gon.prefilled_authors = @article.authors.map { |a| {id: a.id, name: a.name} } rescue []
    end
end
