class LegacyRedirectController < ApplicationController
  def show_piece
    volume = params[:volume]
    number = params[:number]
    archivetag = params[:archivetag][0...-5]

    slug = "#{archivetag}-#{volume}-#{number}".downcase

    piece = Piece.find_by!(slug: slug)
    redirect_to piece.frontend_display_path
  end
end
