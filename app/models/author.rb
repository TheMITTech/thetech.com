class Author < AbstractModel
  include Paperclip::Glue
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :portrait, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/default_author_portrait.png"
  validates_attachment_content_type :portrait, :content_type => /\Aimage\/.*\Z/

  validates :name, presence: true, length: {minimum: 1, maximum: 200}
  validates :email, presence: false, email: true, if: '!email.blank?'
  validates :bio, length: {maximum: 10000}

  has_many :authorships
  has_many :drafts, through: :authorships

  has_many :images

  scope :recent_photographers, -> { joins(:images).where('images.created_at > ?', 2.year.ago).distinct }
  scope :new_authors, -> { where('created_at > ?', 1.week.ago) }

  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end

  def as_react(ability)
    as_json only: [:id, :name]
  end
end
