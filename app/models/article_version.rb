class ArticleVersion < ActiveRecord::Base
  belongs_to :article

  serialize :contents

  default_scope { order('created_at DESC') }

  def headline
    self.article_params[:headline]
  end

  def article_params
    self.contents[:article_params]
  end

  def piece_params
    self.contents[:piece_params]
  end
end
