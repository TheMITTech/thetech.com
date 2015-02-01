class ArticleVersionsController < ApplicationController

  load_and_authorize_resource

  def index
    @article = Article.find(params[:article_id])
    @versions = @article.article_versions
  end

  def show
    @version = ArticleVersion.find(params[:id])

    @article = Article.new
    @article.assign_attributes(@version.article_attributes)
    @piece = Piece.new
    @piece.assign_attributes(@version.piece_attributes)

    @title = @article.headline

    require 'renderer'
    renderer = Techplater::Renderer.new(@piece.web_template, @article.chunks)
    @html = renderer.render

    @web_status_options = ArticleVersion::WEB_STATUS_NAMES.reject {|k, v|
      k == :web_published and not @version.web_published?
    }.keys.map {|k| [ArticleVersion::WEB_STATUS_NAMES[k], k]}

    render 'show', layout: 'bare'
  end

  def revert
    @version = ArticleVersion.find(params[:id])

    article_params = @version.article_params
    piece_params = @version.piece_params
    article_params = article_params.permit! if article_params.respond_to?(:permit!)
    piece_params = piece_params.permit! if piece_params.respond_to?(:permit!)

    @article = @version.article
    @article.assign_attributes(article_params)
    @piece = @article.piece
    @piece.assign_attributes(piece_params)

    gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
    gon.prefilled_authors = @article.authors.map { |a| {id: a.id, name: a.name} } rescue []

    render 'articles/edit'
  end

  def update_web_status
    @version = ArticleVersion.find(params[:id])
    @version.update(params[:article_version].permit(:web_status))

    redirect_to :back, flash: {success: 'You have successfully changed the status of this article version. '}
  end

  def mark_print_ready
    @version = ArticleVersion.find(params[:id])
    @version.dup.print_ready!

    redirect_to article_article_versions_path(@version.article), flash: {success: 'You have successfully marked the version as ready for print. '}
  end
end
