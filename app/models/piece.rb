class Piece < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  acts_as_ordered_taggable

  has_and_belongs_to_many :images
  has_and_belongs_to_many :series

  belongs_to :section
  belongs_to :issue

  has_one :article, autosave: false

  before_save :update_tag_list

  NO_PRIMARY_TAG = 'NO_PRIMARY_TAG'

  # Virtual attribute primary_tag and normal_tags. Both string
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
    self.taggings.map(&:tag).map(&:name)
  end

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

  # Return a human-readable name of the piece. For now, if the piece contains article(s), return the title of the first article. Otherwise, if it contains images, return the caption of the first image. If it contains neither, return 'Empty piece'. Might need a better approach. FIXME
  def name
    return self.article.headline if self.article

    if self.images.any?
      caption = self.images.first.caption

      if caption.blank?
        return 'Uncaptioned Image'
      else
        return caption
      end
    end

    'Empty piece'
  end

  def title
    if self.primary_tag
      "#{primary_tag.upcase}: #{self.name}"
    else
      self.name
    end
  end

  def slug_candidates
    if self.article
      [
        :article_headline,
        :article_subhead,
        [:article_headline, :issue_volume, :issue_number],
        [:article_subhead, :issue_volume, :issue_number]
      ]
    else
      [
        :image_caption,
        [:image_caption, :issue_volume, :issue_number]
      ]
    end
  end

  def should_generate_new_friendly_id?
    true
  end

  # Wrapper accessors for friendly_id
  def article_headline
    self.article.headline
  end

  def article_subhead
    self.article.subhead
  end

  def issue_volume
    self.issue.volume
  end

  def issue_number
    self.issue.number
  end

  def image_caption
    self.images.first.try(:caption)
  end

  private
    def update_tag_list
      self.tag_list = [self.primary_tag || NO_PRIMARY_TAG] + self.tags
    end
end
