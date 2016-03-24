class Section < AbstractModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pieces

  scope :btf, -> { find([1, 3, 4, 5, 6]) }
end
