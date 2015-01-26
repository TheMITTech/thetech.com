class Piece < ActiveRecord::Base
  default_scope { order('created_at DESC') }

  scope :recent, -> { order('created_at DESC').limit(20) }
  scope :with_article, -> { where(:id => Article.select(:piece_id).uniq) }
  scope :with_image, -> { where(:id => Image.select(:primary_piece_id).uniq) }

  acts_as_ordered_taggable

  has_and_belongs_to_many :images
  has_and_belongs_to_many :series

  belongs_to :section
  belongs_to :issue

  has_one :article, autosave: false
  has_one :image, autosave: false, foreign_key: 'primary_piece_id'

  before_save :update_tag_list

  validates :slug, presence: true, uniqueness: true, length: {minimum: 5, maximum: 80}, format: {with: /\A[a-z0-9-]+\z/}
  validates_presence_of :section
  validates_presence_of :issue

  NO_PRIMARY_TAG = 'NO_PRIMARY_TAG'

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
    when :tags, :primary_tag, :slug
      self.send(name)
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
    date = self.publish_datetime

    Rails.application.routes.url_helpers.frontend_piece_path(
      '%04d' % date.year,
      '%02d' % date.month,
      '%02d' % date.day,
      self.slug
    )
  end

  private
    def update_tag_list
      self.tag_list = [self.primary_tag || NO_PRIMARY_TAG] + self.tags
    end
end
