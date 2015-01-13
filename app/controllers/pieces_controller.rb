class PiecesController < ApplicationController
  before_action :set_piece, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  respond_to :html

  def index
    @pieces = Piece.all
    respond_with(@pieces)
  end

  def show
    respond_with(@piece)
  end

  def new
    @piece = Piece.new
    respond_with(@piece)
  end

  def edit
  end

  def create
    @piece = Piece.new(piece_params)
    @piece.save
    respond_with(@piece)
  end

  def update
    @piece.update(piece_params)
    respond_with(@piece)
  end

  def destroy
    @piece.destroy
    respond_with(@piece)
  end

  private
    def set_piece
      @piece = Piece.find(params[:id])
    end

    def piece_params
      params.require(:piece).permit(:web_template)
    end
end
