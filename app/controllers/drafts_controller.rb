class DraftsController < ApplicationController
  # REBIRTH_TODO: Authorization?

  load_and_authorize_resource :article
  load_and_authorize_resource :draft, through: :article

  before_filter :load_objects, only: [:show, :update, :publish]

  def index
    @article = Article.find(params[:article_id])
    @drafts = @article.drafts.order('created_at ASC')

    respond_to do |f|
      f.html
      f.json { render json: {drafts: @drafts.map { |d| d.as_react(current_ability, include_text: true)} } }
    end
  end

  def show
  end

  def publish
    @draft.web_published!
    @draft.update!(published_at: Time.zone.now)

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

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
    if draft_params[:web_status].try(:to_sym) == :web_ready or
       draft_params[:print_status].try(:to_sym) == :print_ready
      authorize! :ready, @draft.article
    end

    @draft.update!(draft_params)

    respond_to do |f|
      f.html { redirect_to :back, flash: {success: "Operation succeeded. "} }
      f.json { render json: {draft: @draft.as_react(current_ability, include_text: true)} }
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