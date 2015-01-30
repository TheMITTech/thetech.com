class FrontendHomepageController < FrontendController
  def show
    @homepage = Homepage.published
    render 'show_homepage', layout: 'frontend'
  end
end