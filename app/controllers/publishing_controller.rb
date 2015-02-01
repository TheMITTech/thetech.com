class PublishingController < ApplicationController
  def show
  	articles = ArticleVersion.web_ready.map(&:article)
  end

  def publish
  end
end
