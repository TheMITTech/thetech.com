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
  end

  def show
    @articles = @author.articles.map(&:as_display_json)
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
      @author = Author.friendly.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :email, :bio, :portrait)
    end
end
