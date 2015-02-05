# Schema information
#
# table: images
#
# caption		text
# attribution		text
# created_at		datetime
# updated_at 		datetime

class Image < AbstractModel
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pieces

  enum web_status: [:web_draft, :web_published, :web_ready]
  enum print_status: [:print_draft, :print_ready]

  WEB_STATUS_NAMES = {
    web_draft: "Web Draft",
    web_published: "Web Published",
    web_ready: "Ready for Web"
  }

  PRINT_STATUS_NAMES = {
    print_draft: "Print Draft",
    print_ready: "Ready for Print"
  }

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

  def web_statuses_for_select
    if self.web_published?
      [:web_published]
    else
      Image.web_statuses.keys.reject { |k| k.to_sym == :web_published }
    end
  end

  private
end
