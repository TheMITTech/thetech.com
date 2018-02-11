class Section < AbstractModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :articles

  def as_react(ability)
    self.as_json only: [:id, :name]
  end

  def self.btf
    return [
      find_by!(name: 'News'),
      find_by!(name: 'Opinion'),
      find_by!(name: 'Arts'),
      find_by!(name: 'Sports'),
      find_by!(name: 'Campus Life'),
      find_by!(name: 'Science'),
    ]
  end
end
