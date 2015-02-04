class Author < AbstractModel
  include Paperclip::Glue
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :portrait, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/default_author_portrait.png"
  validates_attachment_content_type :portrait, :content_type => /\Aimage\/.*\Z/

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
