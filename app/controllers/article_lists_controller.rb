class ArticleListsController < ApplicationController
  before_action :set_article_list, only: [:show, :edit, :update, :destroy, :append_item, :remove_item]

  respond_to :html

  def index
    @article_lists = ArticleList.all
    respond_with(@article_lists)
  end

  def show
    respond_with(@article_list)
  end

  def new
    @article_list = ArticleList.new
    respond_with(@article_list)
  end

  def edit
  end

  def create
    @article_list = ArticleList.new(article_list_params)
    @article_list.piece = Piece.find(params[:piece_id])
    @article_list.save
    respond_with(@article_list)
  end

  def update
    @article_list.update(article_list_params)
    respond_with(@article_list)
  end

  def destroy
    @article_list.destroy
    respond_with(@article_list)
  end

  def append_item
    item = ArticleListItem.new(article_list_item_params)
    item.article_list = @article_list
    item.save

    redirect_to article_list_path(@article_list), flash: {success: 'Item appended. '}
  end

  def remove_item
    ArticleListItem.find(params[:article_list_item_id]).destroy

    redirect_to article_list_path(@article_list), flash: {success: 'Item removed. '}
  end

  private
    def set_article_list
      @article_list = ArticleList.find(params[:id])
    end

    def article_list_params
      params.require(:article_list).permit(:name, :piece_id)
    end

    def article_list_item_params
      params.permit(:piece_id)
    end
end
