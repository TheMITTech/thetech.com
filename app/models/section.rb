class Section < AbstractModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pieces
end
