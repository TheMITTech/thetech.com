class Section < AbstractModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :articles

  # TODO: WOW...
  scope :btf, -> { find([1, 3, 4, 5, 6]) }
end
