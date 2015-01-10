class Piece < ActiveRecord::Base
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
end
