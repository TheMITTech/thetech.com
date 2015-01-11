class Author < ActiveRecord::Base
  validates :name, presence: true, length: {minimum: 1, maximum: 200}
  validates :email, presence: false, email: true, if: '!email.blank?'
  validates :bio, length: {maximum: 1000}

  def articles
    Piece.all.select { |p| p.article && p.article.author_ids.split(",").include?(id.to_s) }
  end
end
