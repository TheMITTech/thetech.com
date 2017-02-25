# Schema information
#
# table: images
#
# caption		text
# attribution		text
# created_at		datetime
# updated_at 		datetime

class PreRebirthImage < AbstractModel
  include ExternalFrontendUrlHelper

  has_and_belongs_to_many :pieces, foreign_key: 'image_id'

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

  has_many :pictures, foreign_key: 'image_id'
  belongs_to :author

  before_save :update_search_content

  after_save :update_piece_published_at
  after_update :purge_varnish_cache

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

  # Elastic search query
  def self.search(query)
    field_query = {
      query: query,
      operator: 'and'
    }

    self.__elasticsearch__.search({
      sort: [
        updated_at: 'desc'
      ],
      query: {
        match: {search_content: field_query}
      }
    })
  end

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
        assigned_pieces: self.pieces.map(&:article).compact.map(&:as_display_json),
        caption: self.caption,
        attribution: self.attribution,
        section_name: self.primary_piece.try(:section).try(:name),
        issue: {volume: self.primary_piece.try(:issue).try(:volume), number: self.primary_piece.try(:issue).try(:number)},
        thumbnail_path: self.primary_picture_url(:thumbnail),
        print_status: self.print_status.to_sym,
        web_status: self.web_status.to_sym
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

  def associated_piece
    self.primary_piece || self.pieces.first
  end

  def author_id=(id)
    if id.present?
      super(id.to_i)
    else
      super(nil)
    end
  end

  protected
    def update_piece_published_at
      return unless self.web_published?
      return if self.primary_piece.nil?
      return unless self.primary_piece.published_at.nil?

      self.primary_piece.update(published_at: self.updated_at)
    end

    def purge_varnish_cache
      require 'varnish/purger'

      if self.web_published?
        Varnish::Purger.purge(external_frontend_photographer_url(Author.find(self.author_id_was)), true) if self.author_id_was
        Varnish::Purger.purge(external_frontend_photographer_url(Author.find(self.author_id)), true) if self.author_id
      end
    end

    def update_search_content
      author_name = self.author.name rescue ''

      self.search_content = [author_name, self.caption, self.attribution].join(' ')
    end
end