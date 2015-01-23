class ArticleVersion < ActiveRecord::Base
  belongs_to :article
  belongs_to :user

  serialize :contents

  enum web_status: [:web_draft, :web_published]
  enum print_status: [:print_draft, :print_ready]

  default_scope { order('created_at DESC, id DESC') }

  after_save :invalidate_article_cache

  def headline
    self.article_params[:headline]
  end

  def article_params
    self.contents[:article_params]
  end

  def piece_params
    self.contents[:piece_params]
  end

  def article_attributes
    self.contents[:article_attributes]
  end

  def piece_attributes
    self.contents[:piece_attributes]
  end

  private
    def invalidate_article_cache
      Rails.cache.delete("#{self.article.cache_key}/display_json")
    end
end
