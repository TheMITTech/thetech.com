class DraftsController < ApplicationController
  # REBIRTH_TODO: Authorization?

  before_filter :load_objects, only: [:show, :update, :publish]

  def index
    @article = Article.find(params[:article_id])
    @drafts = @article.drafts.order('created_at DESC')
  end

  def show
  end

  def publish
    @draft.web_published!
    @draft.update!(published_at: Time.zone.now)

    respond_to do |f|
      f.html { redirect_to publishing_dashboard_path, flash: {success: "You have successfully published \"#{@draft.headline}\". "} }
      f.json { render json: {article: @draft.article.as_react(current_ability)} }
    end
  end

  # This action mutates a given Draft in-place. Note that this should
  # be used sparingly, e.g. only for cases of print/web status changes.
  #
  # For creating a new Draft for a given Article, see articles#update.
  def update
    @draft.update!(draft_params)

    respond_to do |f|
      f.html { redirect_to :back, flash: {success: "Operation succeeded. "} }
      f.js
    end
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