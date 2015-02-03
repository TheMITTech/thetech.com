class FrontendSectionsController < FrontendController
  def show
    @section = Section.friendly.find(params[:id])
    @pieces = @section.pieces.with_published_article.page(params[:page]).per(20)
    @articles = @pieces.map(&:article).map(&:latest_published_version)

    render 'show', layout: 'frontend'
  end
end
