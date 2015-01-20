class ArticleList < ActiveRecord::Base
  belongs_to :piece
  has_many :article_list_items

  def to_placeholder_html
    [
      "<ol class='asset_article_list'>",
      article_list_items.map { |i| "<li>#{i.piece.title}</li>" }.join(''),
      "</ol>"
    ].join('')
  end
end
