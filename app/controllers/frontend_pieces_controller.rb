class FrontendPiecesController < ApplicationController
  def show
    piece = Piece.find_by!(slug: params[:slug])

    datetime = piece.publish_datetime

    if params[:year].to_d != datetime.year ||
       params[:month].to_d != datetime.month ||
       params[:day].to_d != datetime.day
      raise_404
    else
      render 'show', layout: 'frontend'
    end
  end
end
