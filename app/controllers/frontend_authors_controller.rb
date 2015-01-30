class FrontendAuthorsController < FrontendController
  def show
    @author = Author.friendly.find(params[:id])
    @articles = @author.articles.select(&:published?).map(&:display_version).sort_by(&:created_at).reverse

    render 'show', layout: 'frontend'
  end
end
