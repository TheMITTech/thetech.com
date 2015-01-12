class ArticleVersionsController < ApplicationController
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

    render 'show', layout: 'bare'
  end

  def revert
    @version = ArticleVersion.find(params[:id])
    @article = @version.article
    @article.assign_attributes(@version.article_params.permit!)
    @piece = @article.piece
    @piece.assign_attributes(@version.piece_params.except(:id).permit!)

    render 'articles/edit'
  end
end
