class FrontendAuthorsController < FrontendController
  def show
    @author = Author.friendly.find(params[:id])
    @o_articles = @author.articles.published.page(params[:page]).per(20)
    @articles = @o_articles.map(&:display_version).sort_by(&:created_at).reverse

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
