class FrontendHomepageController < FrontendController

  before_action :set_cache_control_headers, only: [:show]

  def show
    @latest_issue = Issue.where('published_at <= ?', Time.now).order('published_at DESC').first

    @homepage = Homepage.latest_published
    set_cache_control_headers(24.hours)
    render 'show_homepage', layout: 'frontend'
  end

  def weather
    set_cache_control_headers(15.minutes)
    render 'weather', layout: false
  end

end
