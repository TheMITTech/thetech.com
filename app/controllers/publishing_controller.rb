class PublishingController < ApplicationController

  def dashboard
    @title = "Publish"
    authorize! :show, :dashboard

    @pending_homepages = Homepage.publish_ready.where('created_at >= ?', Homepage.latest_published.created_at).order('created_at DESC')
  end
end
