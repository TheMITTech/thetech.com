class ArticlesController < ApplicationController
  before_action :prepare_authors_json, only: [:new, :edit]

  load_and_authorize_resource

  def index
    # Rough query syntax:
    #
    # If query looks like "  v343 N9394    " or "V134/N61" or "v100n1"
    #   then the articles from that issue are returned.
    # Otherwise
    #   articles are searched for matching headline or other metadata.

    @page = (params[:page].presence || 1).to_i

    if params[:q].blank?
      respond_to do |f|
        f.html
        f.json do
          @articles = Article.order('created_at DESC').page(@page).per(20)

          next_page = @articles.last_page? ?
                      nil :
                      articles_path(page: @page + 1, format: :json)

          render json: {articles: @articles.map { |a| a.as_react(current_ability) }, nextPage: next_page}
        end
      end
    else
      match = /^\s*V(\d+)[ \/]?N(\d+)\s*$/i.match(params[:q])
      unless match.nil?
        issue = Issue.find_by(volume: match[1].to_i, number: match[2].to_i)
        @articles = issue.articles rescue []
      else
        drafts = Draft.search_query(params[:q]).order('created_at DESC').limit(100)
        @articles = drafts.map(&:article).uniq
      end

      respond_to do |f|
        f.html
        f.json { render json: {articles: @articles.map { |a| a.as_react(current_ability) }, nextPage: nil} }
        f.js
      end
    end
  end

  def show
    respond_to do |f|
      f.json { render json: {article: @article.as_react(current_ability)} }
    end
  end

  def new
    @article = Article.new
    @draft = Draft.new
  end

  # This action creates BOTH a new Article, and a corresponding first Draft
  def create
    @article = Article.new(article_params)
    @draft = @article.drafts.build(draft_params)
    @draft.user = current_user

    if @article.valid? && @draft.valid?
      @article.save!
      @draft.save!

      redirect_to article_draft_path(@article, @draft), flash: {success: "You have successfully created an article. "}
    else
      @errors_compiled = @article.errors.full_messages + @draft.errors.full_messages

      if @errors_compiled.include? "Slug can't be blank"
        @errors_compiled.delete "Slug is too short (minimum is 5 characters)"
        @errors_compiled.delete "Slug is invalid"
      elsif @errors_compiled.include? "Slug is too short (minimum is 5 characters)"
        @errors_compiled.delete "Slug is invalid"
      end

      if @errors_compiled.include? "Headline can't be blank"
        @errors_compiled.delete "Headline is too short (minimum is 2 characters)"
      end

      @flash[:error] = (@errors_compiled).join("\n")
      prepare_authors_json
      render 'new'
    end
  end

  def edit
    @draft = @article.drafts.find(params[:draft_id])
    gon.prefilled_authors = @draft.authors.map { |a| a.as_json(only: [:id, :name]) }
  end

  # This action modifies fields in a given Article object.
  # If params[:draft] is present, this action also creates a new Draft for the
  # given Article. This action NEVER mutates a Draft object.
  #
  # For changing a Draft object in-place, see drafts#update.
  def update
    @article.assign_attributes(article_params)
    @draft = @article.drafts.build(draft_params)
    @draft.user = current_user

    if @article.valid? && @draft.valid?
      @article.save!
      @draft.save!

      if !allowed_params[:update].nil?
        flash[:success] = "You have successfully updated the article. "
        return render js: "window.location = '#{article_draft_path(@article, @draft)}'; "
      end
    else
      @errors = (@article.errors.full_messages + @draft.errors.full_messages).join("\n")
    end
  end

  def update_rank
    @article.assign_attributes(article_params)
    @article.save!

    respond_to do |f|
      f.json { render json: {article: @article.as_react(current_ability)} }
    end
  end

  def destroy
    @article.destroy

    respond_to do |f|
      f.html { redirect_to :back, flash: {success: "You have successfully deleted the article. "} }
      f.json { render json: {article: {id: @article.id, destroyed: true}} }
    end
  end

  # TODO: Currently we publish Draft but unpublishes Article. Are we OCD enough to fix it?
  def unpublish
    @article.drafts.web_published.each do |article|
      article.web_ready!
    end

    # Invalidate below_fold fragment cache when new content is published/unpublished
    ActionController::Base.new.expire_fragment("below_fold")

    respond_to do |f|
      f.html { rediret_to :back, flash: {success: "You have successfully unpublished the article. "} }
      f.json { render json: {article: @article.as_react(current_ability)} }
    end
  end

  # TODO: Currently we publish Draft but unpublishes Article. Are we OCD enough to fix it?
  def unpublish
    @article.drafts.web_published.each do |article|
      article.web_ready!
    end

    respond_to do |f|
      f.html { rediret_to :back, flash: {success: "You have successfully unpublished the article. "} }
      f.js
    end
  end

  private
    def allowed_params
      params.permit(
        :save,
        :update,
        article: [:issue_id, :section_id, :slug, :syndicated, :allow_ads, :brief, :rank, :update, :save],
        draft: [:primary_tag, :secondary_tags, :headline, :subhead, :comma_separated_author_ids, :bytitle, :social_media_blurb, :sandwich_quotes, :attribution, :redirect_url, :lede, :html]
      )
    end

    def article_params
      allowed_params[:article]
    end

    def draft_params
      allowed_params[:draft]
    end

    def prepare_authors_json
      gon.authors = Author.all.map { |a| {id: a.id, name: a.name} }
    end
end
