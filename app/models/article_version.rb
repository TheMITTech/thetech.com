class ArticleVersion < AbstractModel
  belongs_to :article
  belongs_to :user

  serialize :contents

  enum web_status: [:web_draft, :web_published, :web_ready]
  enum print_status: [:print_draft, :print_ready]

  WEB_STATUS_NAMES = {
    web_draft: 'Draft',
    web_published: 'Published on the web',
    web_ready: 'Ready for web'
  }

  default_scope { order('created_at DESC, id DESC') }

  after_save :invalidate_article_cache

  # Returns a string representation of the article's headline.
  def headline
    self.article_attributes[:headline]
  end

  def subhead
    self.article_attributes[:subhead]
  end

  def content
    self.article_attributes[:html]
  end

  def section_id
    self.piece_attributes[:section_id]
  end

  # Returns a hash of article_params
  def article_params
    self.contents[:article_params]
  end

  # Returns a hash of piece_params
  def piece_params
    self.contents[:piece_params]
  end

  # Returns a hash of article_attributes
  def article_attributes
    self.contents[:article_attributes].with_indifferent_access
  end

  # Returns a hash of piece_attributes
  def piece_attributes
    self.contents[:piece_attributes].with_indifferent_access
  end

  def author_ids
    self.contents[:author_ids]
  end

  def tag_ids
    self.contents[:tag_ids]
  end

  def meta(name)
    self.build_article.meta(name) || self.build_piece.meta(name)
  end

  def build_article
    Article.new(article_attributes)
  end

  def build_piece
    Piece.new(piece_attributes)
  end

  private
    def invalidate_article_cache
      Rails.cache.delete("#{self.article.cache_key}/display_json")
    end
end
