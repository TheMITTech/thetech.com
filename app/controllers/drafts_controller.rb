class DraftsController < ApplicationController
  # REBIRTH_TODO: Authorization?

  before_filter :load_objects, only: [:show]

  def index
    @article = Article.find(params[:article_id])
    @drafts = @article.drafts
  end

  def show
  end

  private
    def load_objects
      @draft = Draft.find(params[:id])
      @article = @draft.article
    end
end