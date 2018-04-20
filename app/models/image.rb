# REBIRTH_TODO: Cache invalidation.
# REBIRTH_TODO: Investigate consequences of removing :associated_piece.

class Image < ActiveRecord::Base
  include MessageBusPublishable

  has_attached_file :web_photo,
    path: ":class/:attachment/:style/:id_:filename",
    preserve_files: true,
    styles: {
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
  has_many :legacy_comments, dependent: :destroy, as: :legacy_commentable

  acts_as_paranoid

  # Frontend search related stuff
  searchkick ignore_above: 32767, index_prefix: (ENV["ELASTICSEARCH_PREFIX"].presence || "development"), batch_size: 100

  scope :search_import, -> { web_published }

  default_scope { includes(:issue, :author, :articles) }

  def should_index?
    self.web_published?
  end

  def search_data
    {
      caption: self.caption,
      attribution: self.attribution,
      author: self.author.try(:name),
      articles: self.articles.web_published.map(&:newest_web_published_draft).map(&:headline).join("\n"),
      published_at: self.published_at,
    }
  end

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

  # If the image has an author, we use that.
  # Otherwise, we use the attribution string.
  def attribution_text
    self.author.present? ?
      "#{self.author.name} – The Tech" :
      "#{self.attribution}"
  end

  def as_react(ability)
    (as_json only: [:id, :caption, :attributio, :web_status, :print_status]).merge(
      author: self.author.try(:as_react, ability),
      attribution_text: self.attribution_text,
      web_photo_thumbnail_url: self.web_photo.url(:thumbnail),
      articles: self.articles.map { |i| i.as_react(ability) },

      can_publish: ability.can?(:publish, self),
      can_unpublish: ability.can?(:unpublish, self),
      can_update: ability.can?(:update, self),
      can_ready: ability.can?(:ready, self),
      can_destroy: ability.can?(:destroy, self),
      can_add_article: ability.can?(:add_article, self),
      can_remove_article: ability.can?(:remove_article, self),
    )
  end
end
