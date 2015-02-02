class FrontendTagsController < FrontendController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by(slug: params[:id])
    @pieces = Piece.tagged_with(@tag).with_published_article.page(params[:page]).per(20)
    @articles = @pieces.map(&:article).map(&:latest_published_version)

    render 'show', layout: 'frontend'
  end
end
