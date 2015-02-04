class FrontendSectionsController < FrontendController
  def show
    @section = Section.friendly.find(params[:id])
    @pieces = @section.pieces.with_published_article.page(params[:page]).per(20)
    @articles = @pieces.map(&:article).map(&:latest_published_version)

    set_cache_control_headers(24.hours)
    render 'show', layout: 'frontend'
  end
end
