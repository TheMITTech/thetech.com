class FrontendAuthorsController < ApplicationController
  def show
    @author = Author.find(params[:id])
    @articles = @author.articles.select(&:published?).map(&:display_version)

    render 'show', layout: 'frontend'
  end

  private
    def allowed_in_frontend?
      true
    end
end
