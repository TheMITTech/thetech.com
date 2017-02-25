class PublishingController < ApplicationController

  def dashboard
    authorize! :show, :dashboard

    @pending_drafts = Draft.web_ready.order("created_at DESC").select do |d|
      d == d.article.newest_web_ready_draft &&
      (!d.article.has_web_published_draft? ||
        d.created_at > d.article.newest_web_published_draft.created_at)
    end

    @pending_images = Image.web_ready.order('created_at DESC')
    @pending_homepages = Homepage.publish_ready.where('created_at >= ?', Homepage.latest_published.created_at).order('created_at DESC')
  end
end
