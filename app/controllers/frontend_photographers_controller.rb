class FrontendPhotographersController < FrontendController
  def show
    @author = Author.friendly.find(params[:id])

    query = @author.images.web_published.order('updated_at DESC')
    @images = query
    @count = query.count

    @title = @author.name

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
