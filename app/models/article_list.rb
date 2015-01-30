class ArticleList < AbstractModel
  belongs_to :piece
  has_many :article_list_items

  def to_placeholder_html
    [
      "<ol data-role='asset-article-list' data-article-list-id='#{self.id}'>",
      article_list_items.map { |i| "<li>#{i.piece.title}</li>" }.join(''),
      "</ol>"
    ].join('')
  end
end
