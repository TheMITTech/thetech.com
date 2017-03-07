class Section < AbstractModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :articles

  # TODO: WOW...
  scope :btf, -> { find([1, 3, 4, 5, 6]) }

  def as_react(ability)
    self.as_json only: [:id, :name]
  end
end
