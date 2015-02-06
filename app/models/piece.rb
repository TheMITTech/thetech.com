class Piece < AbstractModel
  include ExternalFrontendUrlHelper

  default_scope { order('updated_at DESC') }

  scope :recent, -> { order('created_at DESC').limit(20) }
  scope :with_article, -> { where(:id => Article.select(:piece_id).uniq) }
  scope :with_image, -> { where(:id => Image.select(:primary_piece_id).uniq) }
  scope :with_published_article, -> { joins(:article).where('articles.latest_published_version_id IS NOT NULL') }

  acts_as_ordered_taggable

  has_and_belongs_to_many :images

  has_many :article_lists

  belongs_to :section
  belongs_to :issue

  has_one :article, autosave: false
  has_one :image, autosave: false, foreign_key: 'primary_piece_id'

  has_many :legacy_comments

  before_save :update_tag_list
  after_save :invalidate_caches

  validates :slug, presence: true, uniqueness: true, length: {minimum: 5, maximum: 80}, format: {with: /\A[a-z0-9-]+\z/}
  validates_presence_of :section
  validates_presence_of :issue

  NO_PRIMARY_TAG = 'NO_PRIMARY_TAG'

  scope :search_query, lambda { |q|
    return nil if q.blank?

    terms = q.downcase.split(/\s+/)

    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 3
    where(
      terms.map { |t|
        "(LOWER(pieces.published_headline) LIKE ? OR LOWER(pieces.published_subhead) LIKE ? OR LOWER(pieces.published_content) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  def thumbnail_picture
    if self.meta(:image)
      self.meta(:image).pictures.first
    elsif self.meta(:article)
      self.meta(:article).asset_images.first.try(:pictures).try(:first)
    elsif
      nil
    end
  end

  # Whether it uses the legacy commenting system
  def uses_legacy_comments?
  end

  # Gives the time of publication of the article or, if the article has not been
  # published, the time of creation of the article. Returns datetime.
  def publish_datetime
    self.article.try(:published_at) || self.created_at
  end

  # Virtual attribute primary_tag. Input must be a string.
  def primary_tag=(primary_tag)
    if primary_tag.blank?
      @primary_tag = NO_PRIMARY_TAG
    else
      @primary_tag = primary_tag
    end
  end

  # Use this instead of the original tag_list function
  # When the object is loaded from version hash, tag_list will not be available
  # However, taggings do work. Therefore, recreate tag_list in this way
  def my_tag_list
    self.taggings.order('id ASC').map(&:tag).map(&:name)
  end

  # Returns the primary tag if one exists, otherwise returns nil. Returns a
  # string.
  def primary_tag
    tag = @primary_tag || my_tag_list.first

    if tag == NO_PRIMARY_TAG
      nil
    else
      tag
    end
  end

  def tags=(normal_tags)
    @tags = normal_tags
  end

  def tags
    @tags ||= my_tag_list.drop(1)
  end

  def tags_string
    self.tags.join(',')
  end

  def tags_string=(tags_string)
    self.tags = tags_string.split(',')
  end

  def meta(name)
    case name
    when :tags, :primary_tag, :slug, :frontend_display_path, :thumbnail_picture
      self.send(name)
    when :display_primary_tag
      self.send(:primary_tag) || self.meta(:section).name
    when :section
      Section.find(self.section_id)
    when :article
      Article.find_by(piece_id: self.id)
    when :image
      Image.find_by(primary_piece_id: self.id)
    when :section_name
      self.meta(:section).try(:name)
    when :publish_datetime
      self.meta(:article).try(:published_at) || self.created_at
    when :uses_legacy_comments?
      self.meta(:legacy_comments).any?
    when :legacy_comments
      LegacyComment.where(piece_id: self.id)
    end
  end

  # Return a human-readable name of the piece. If the piece contains article(s),
  # return the title of the first article. Otherwise, if it contains images,
  # return the caption of the first image. If it contains neither, return
  # 'Empty piece'.
  def name
    return self.article.headline if self.article
    return self.image.caption if self.image

    'Empty piece'
  end

  def title
    if self.primary_tag
      "#{primary_tag.upcase}: #{self.name}"
    else
      self.name
    end
  end

  def frontend_display_path
    date = self.meta(:publish_datetime)

    return nil if date.nil?

    external_frontend_piece_url(
      '%04d' % date.year,
      '%02d' % date.month,
      '%02d' % date.day,
      self.slug
    )
  end

  def web_published?
    self.article ? self.article.web_published? : self.image.web_published?
  end

  private
    def update_tag_list
      self.tag_list = [self.primary_tag || NO_PRIMARY_TAG] + self.tags
    end

    def invalidate_caches
      Rails.cache.delete("#{self.article.cache_key}/display_json") if self.article
      Rails.cache.delete("#{self.image.cache_key}/display_json") if self.image
    end
end
