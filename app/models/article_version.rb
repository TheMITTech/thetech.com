class ArticleVersion < AbstractModel
  belongs_to :article
  belongs_to :user

  serialize :contents

  enum web_status: [:web_draft, :web_published]
  enum print_status: [:print_draft, :print_ready]

  default_scope { order('created_at DESC, id DESC') }

  after_save :invalidate_article_cache

  # Returns a string representation of the article's headline.
  def headline
    self.article_params[:headline]
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
    self.contents[:article_attributes]
  end

  # Returns a hash of piece_attributes
  def piece_attributes
    self.contents[:piece_attributes]
  end

  private
    def invalidate_article_cache
      Rails.cache.delete("#{self.article.cache_key}/display_json")
    end
end
