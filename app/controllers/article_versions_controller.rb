class ArticleVersionsController < ApplicationController
  def index
    @article = Article.find(params[:article_id])
    @versions = @article.article_versions
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
