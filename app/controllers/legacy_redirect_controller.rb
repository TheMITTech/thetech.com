class LegacyRedirectController < FrontendController
  def show_piece
    volume = params[:volume]
    number = params[:number]
    parent = params[:parent]
    parent = parent.gsub(' ', '-').chars.select { |x| /[0-9A-Za-z-]/.match(x) }.join if parent
    archivetag = params[:archivetag][0...-5].gsub(' ', '-').chars.select { |x| /[0-9A-Za-z-]/.match(x) }.join
    slug = nil

    if parent
      slug = "#{parent}-#{archivetag}-#{volume}-#{number}".downcase
    else
      slug = "#{archivetag}-#{volume}-#{number}".downcase
    end

    piece = Piece.find_by!(slug: slug)
    redirect_to piece.frontend_display_path
  end
end
