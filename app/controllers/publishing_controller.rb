class PublishingController < ApplicationController

  def dashboard
    authorize! :show, :dashboard

    potentially_pending_articles = Article.find(Draft.web_ready.pluck(:article_id).uniq)
    @pending_drafts = potentially_pending_articles.map(&:pending_draft).compact

    @pending_images = Image.web_ready.order('created_at DESC')
    @pending_homepages = Homepage.publish_ready.where('created_at >= ?', Homepage.latest_published.created_at).order('created_at DESC')
  end
end
