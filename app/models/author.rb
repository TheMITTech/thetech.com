class Author < AbstractModel
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  validates :name, presence: true, length: {minimum: 1, maximum: 200}
  validates :email, presence: false, email: true, if: '!email.blank?'
  validates :bio, length: {maximum: 10000}

  has_many :articles, through: :authorships
  has_many :authorships

  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end
end
