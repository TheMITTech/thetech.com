class ArticleList < ActiveRecord::Base
  belongs_to :piece
  has_many :article_list_items
end
