class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :incopy_tagged_file]

  respond_to :html

  def index
    @articles = Article.all
    respond_with(@articles)
  end

  def show
    # respond_with(@article)
    render 'show', layout: 'bare'
  end

  def new
    @article = Article.new
    respond_with(@article)
  end

  def edit
  end

  def create
    @article = Article.new(article_params)

    section_id = params[:section_id]

    if @article.valid?
      @article.piece = Piece.new(section_id: section_id)
      @article.save

      redirect_to article_path(@article)
    else
      render 'new'
    end
  end

  def update
    @article.update(article_params)
    @article.piece.update(section_id: params[:section_id])

    respond_with(@article)
  end

  def destroy
    @article.destroy
    respond_with(@article)
  end

  def incopy_tagged_file
    require 'tempfile'

    file = Tempfile.new('incopy_tagged_file', encoding: 'UTF-16LE')
    file.write(@article.incopy_tagged_text)
    file.close

    send_file file.path, filename: "#{@article.title}.txt"
  end

  private
    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:headline, :subhead, :bytitle, :html, :section_id)
    end
end
