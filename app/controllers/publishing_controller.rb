class PublishingController < ApplicationController

  def dashboard
    authorize! :show, :dashboard

    @pending_versions = ArticleVersion.web_ready.order('created_at DESC').to_a
    @pending_versions = @pending_versions.select do |v|
      v.article.latest_published_version.nil? || v.created_at > v.article.latest_published_version.created_at
    end

    @pending_images = Image.web_ready.order('created_at DESC')
    @pending_homepages = Homepage.publish_ready.where('created_at >= ?', Homepage.latest_published.created_at).order('created_at DESC')
  end
end
