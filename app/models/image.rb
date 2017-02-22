# REBIRTH_TODO: Cache invalidation.
# REBIRTH_TODO: Elasticsearch.
# REBIRTH_TODO: Investigate consequences of removing :associated_piece.

class Image < ActiveRecord::Base
  has_attached_file :web_photo, styles: {
    square: "300x300#",
    thumbnail: "150",
    web: "800x800>",
  }

  # Anything that are not explicitly presence-validated can be nil.
  validates :issue, presence: true
  validates_attachment_content_type :web_photo, :content_type => /\Aimage\/.*\Z/
  validates :web_photo, presence: true

  enum web_status: [:web_draft, :web_published, :web_ready]
  enum print_status: [:print_draft, :print_ready]

  WEB_STATUS_NAMES = {
    web_draft: "Web Draft",
    web_published: "Web Published",
    web_ready: "Ready for Web"
  }.with_indifferent_access

  PRINT_STATUS_NAMES = {
    print_draft: "Print Draft",
    print_ready: "Ready for Print"
  }.with_indifferent_access

  belongs_to :issue
  belongs_to :author

  has_and_belongs_to_many :articles

  acts_as_paranoid

  # The scope that returns the list of images matching the given query.
  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/).map { |e|
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

  # Returns the list of possible web_status-es that this image can be set to.
  # If the image is web_published, it cannot be changed back.
  # Otherwise, we can change the web_status to whatever we like (except :web_published).
  def valid_next_web_statuses
    self.web_published? ?
      [:web_published] :
      Image.web_statuses.keys.reject { |k| k.to_sym == :web_published }
  end
end
