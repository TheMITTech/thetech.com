class FrontendAuthorsController < FrontendController
  def show
    @author = Author.friendly.find(params[:id])

    query = Piece.where('published_author_ids ~* ?', "\\y#{@author.id}\\y")
    @pieces = query.page(params[:page]).per(20)
    @count = query.count
    @sections = query.pluck(:published_section_id).to_a.uniq
    @articles = @pieces.map(&:article).map(&:display_version).sort_by(&:created_at).reverse

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
