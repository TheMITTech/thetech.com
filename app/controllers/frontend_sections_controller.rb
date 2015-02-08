class FrontendSectionsController < FrontendController
  def show
    @section = Section.friendly.find(params[:id])

    query = Piece.where(published_section_id: @section.id)
    @pieces = query.page(params[:page]).per(20)
    @count = query.count
    @sections = query.pluck(:published_section_id).to_a.uniq
    @articles = @pieces.map(&:article).map(&:latest_published_version)

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
