class ArticleListItem < ActiveRecord::Base
  belongs_to :article_list
  belongs_to :piece
end
