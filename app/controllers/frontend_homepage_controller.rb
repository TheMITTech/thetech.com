class FrontendHomepageController < FrontendController

  before_action :set_cache_control_headers, only: [:show]

  def show
    @homepage = Homepage.latest_published
    set_cache_control_headers(15.minutes)
    render 'show_homepage', layout: 'frontend'
  end

end
