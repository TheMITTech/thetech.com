class PublishingController < ApplicationController
  def dashboard
  	articles = ArticleVersion.web_ready.map(&:article)
  end

  def publish
  end
end
