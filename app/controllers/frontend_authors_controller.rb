class FrontendAuthorsController < FrontendController
  def show
    @author = Author.friendly.find(params[:id])
    @pieces = Piece.where('published_author_ids ~* ?', "\\y#{@author.id}\\y").page(params[:page]).per(20)
    @articles = @pieces.map(&:article).map(&:display_version).sort_by(&:created_at).reverse

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
