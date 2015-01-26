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

  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/)

    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 2
    where(
      terms.map { |t|
        "(LOWER(images.caption) LIKE ? OR LOWER(images.attribution) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  def primary_picture_url(format)
    if pictures.first
      self.pictures.first.content.url(format)
    else
      nil
    end
  end

  def as_display_json
    Rails.cache.fetch("#{cache_key}/display_json") do
      {
        id: self.id,
        primary_slug: self.primary_piece.try(:slug),
        assigned_pieces: self.pieces.map(&:article).map(&:as_display_json),
        caption: self.caption,
        attribution: self.attribution,
        section_name: self.primary_piece.try(:section).try(:name),
        issue: {volume: self.primary_piece.try(:issue).try(:volume), number: self.primary_piece.try(:issue).try(:number)},
        thumbnail_path: self.primary_picture_url(:thumbnail)
      }
    end
  end

  private
end
