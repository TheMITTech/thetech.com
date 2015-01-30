class Author < AbstractModel
  validates :name, presence: true, length: {minimum: 1, maximum: 200}
  validates :email, presence: false, email: true, if: '!email.blank?'
  validates :bio, length: {maximum: 10000}

  has_many :articles, through: :authorships
  has_many :authorships

end
