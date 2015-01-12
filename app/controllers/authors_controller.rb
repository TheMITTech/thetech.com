class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

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
    @author_articles = Article.search_query(params[:q]).order('created_at DESC').limit(100)

    @json_articles = @author_articles.map do |a|
      {
        slug: a.piece.friendly_id,
        section_name: a.piece.section.name,
        headline: a.headline,
        subhead: a.subhead,
        authors_line: a.authors_line,
        bytitle: a.bytitle,
        path: article_path(a),
        edit_path: edit_article_path(a)
      }
    end

    gon.articles = @json_articles
    puts gon.articles

    respond_to do |format|
      format.html
      format.json { render json: @json_articles }
    end
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
