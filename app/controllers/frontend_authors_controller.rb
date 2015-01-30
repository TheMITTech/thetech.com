class FrontendAuthorsController < ApplicationController
  def show
    @author = Author.find(params[:id])
    @articles = @author.articles.select(&:published?).map(&:display_version).sort_by(&:created_at).reverse

    render 'show', layout: 'frontend'
  end

  private
    def allowed_in_frontend?
      true
    end
end
