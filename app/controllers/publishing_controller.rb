class PublishingController < ApplicationController
  def dashboard
    @pending_versions = ArticleVersion.web_ready.order('created_at DESC').uniq { |v| v.article_id }
    @pending_images = Image.web_ready.order('created_at DESC')
    @pending_homepages = Homepage.publish_ready.order('updated_at DESC')
  end
end
