class PublishingController < ApplicationController
  def dashboard
    @pending_versions = ArticleVersion.web_ready.order('created_at DESC').uniq { |v| v.article_id }
  end
end
