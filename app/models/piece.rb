class Piece < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  acts_as_ordered_taggable

  has_and_belongs_to_many :images
  has_and_belongs_to_many :series

  belongs_to :section
  belongs_to :issue

  has_one :article, autosave: false

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

  def comma_separated_tag_list
    tag_list.join(", ")
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

end
