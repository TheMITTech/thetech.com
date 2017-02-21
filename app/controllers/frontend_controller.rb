class FrontendController < ApplicationController
  layout 'frontend'

  def homepage
    @latest_issue = Issue.latest_published
    @homepage = Homepage.latest_published
    set_cache_control_headers(1.hours)
  end

  def article
    # REBIRTH_TODO: check wrong date?
    @article = Article.find_by(slug: params[:slug])
    raise_404 && return if @article.nil?

    @draft = @article.newest_web_published_draft
    raise_404 && return if @draft.nil?

    return redirect_to @draft.redirect_url if @draft.redirect_url.present?
  end

  def section
    # REBIRTH_TODO
  end

  def author
  end

  def photographer
  end

  def tag
  end

  def issue_index
  end

  def issue
  end

  private
    def allowed_in_frontend?
      true
    end

    def set_cache_control_headers(age = 24.hours)
      request.session_options[:skip] = true
      response.headers["Cache-Control"] = "public, max-age=#{age}"
    end
end