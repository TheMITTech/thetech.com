class DraftsController < ApplicationController
  # REBIRTH_TODO: Authorization?

  before_filter :load_objects, only: [:show, :update]

  def index
    @article = Article.find(params[:article_id])
    @drafts = @article.drafts
  end

  def show
  end

  # This action mutates a given Draft in-place. Note that this should
  # be used sparingly, e.g. only for cases of print/web status changes.
  #
  # For creating a new Draft for a given Article, see articles#update.
  def update
    @draft.update!(draft_params)
    redirect_to :back, flash: {success: "Operation succeeded. "}
  end

  private
    def load_objects
      @draft = Draft.find(params[:id])
      @article = @draft.article
    end

    def draft_params
      params.require(:draft).permit(:print_status, :web_status)
    end
end