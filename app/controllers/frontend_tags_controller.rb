class FrontendTagsController < ApplicationController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by(slug: params[:id])
    @articles = Piece.tagged_with(@tag).select(&:article).map(&:article).select(&:published?).map(&:display_version).sort_by(&:created_at).reverse

    render 'show', layout: 'frontend'
  end
end
