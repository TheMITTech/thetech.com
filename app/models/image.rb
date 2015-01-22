# Schema information
#
# table: images
#
# caption			text
# attribution		text
# created_at		datetime
# updated_at 		datetime

class Image < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pieces

  belongs_to :primary_piece, class_name: 'Piece'

  has_many :pictures

  validates :caption, presence: true, length: {minimum: 2}

  def primary_picture_path
    if pictures.first
      Rails.application.routes.url_helpers.direct_image_picture_path(self, self.pictures.first)
    else
      nil
    end
  end

  def as_display_json
    {
      id: self.id,
      primary_slug: self.primary_piece.try(:slug),
      assigned_pieces: self.pieces.map(&:article).map(&:as_display_json),
      caption: self.caption,
      attribution: self.attribution,
      section_name: self.primary_piece.try(:section).try(:name),
      issue: {volume: self.primary_piece.try(:issue).try(:volume), number: self.primary_piece.try(:issue).try(:number)},
      thumbnail_path: self.primary_picture_path
    }
  end

  private
end
