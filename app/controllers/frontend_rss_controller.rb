class FrontendRssController < FrontendController
  def feed
    @articles = Piece.with_published_article.limit(20)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
