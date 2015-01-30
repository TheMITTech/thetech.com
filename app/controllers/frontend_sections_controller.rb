class FrontendSectionsController < FrontendController
  def show
    @section = Section.friendly.find(params[:id])
    @articles = @section.pieces.with_article.map(&:article).map(&:display_version)

    render 'show', layout: 'frontend'
  end
end
