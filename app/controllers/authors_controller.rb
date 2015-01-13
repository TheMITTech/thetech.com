class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  respond_to :html

  def index
    @authors = Author.all

    respond_to do |format|
      format.html
      format.json { render json: @authors.to_json(only: [:id, :name]) }
    end

    # respond_with(@authors)
  end

  def show
    @published_articles_by_author = @author.articles.select {|article| article.published?}
    @published_versions = @published_articles_by_author.map {|article| article.display_version.article}
    respond_with(@author)
  end

  def new
    @author = Author.new
    respond_with(@author)
  end

  def edit
  end

  def create
    @author = Author.new(author_params)
    @author.save
    respond_with(@author)
  end

  def update
    @author.update(author_params)
    respond_with(@author)
  end

  def destroy
    @author.destroy
    respond_with(@author)
  end

  private
    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :email, :bio)
    end
end
