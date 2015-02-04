class FrontendStaticPagesController < FrontendController
  REDIRECTS = {
    'ads' => 'ads/index'
  }
  def show
    @name = params[:name].gsub('-', '_')
    @nav_name = @name.split('/').first

    redirect_to external_frontend_static_page_url(REDIRECTS[@name]) and return if REDIRECTS[@name]

    render 'frontend_static_pages/' + @name, layout: 'frontend_static_pages'
  end
end
