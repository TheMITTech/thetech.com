class FrontendHomepageController < FrontendController

  before_action :set_cache_control_headers, only: [:show]

  def show
    @latest_issue = Issue.latest_published

    @homepage = Homepage.latest_published
    set_cache_control_headers(24.hours)
    render 'show_homepage', layout: 'frontend'
  end

  def weather
    set_cache_control_headers(15.minutes)
    render 'weather', layout: false
  end

end
