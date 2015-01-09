class Piece < ActiveRecord::Base
  has_and_belongs_to_many :images
  has_and_belongs_to_many :series

  has_one :article, autosave: false

  # Return a human-readable name of the piece. For now, if the piece contains article(s), return the title of the first article. Otherwise, if it contains images, return the caption of the first image. If it contains neither, return 'Empty piece'. Might need a better approach. FIXME
  def name
    return self.article.headline if self.article
    return self.images.first.caption if self.images.any?
    'Empty piece'
  end
end
