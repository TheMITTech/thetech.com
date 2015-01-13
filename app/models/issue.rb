class Issue < ActiveRecord::Base
  has_many :pieces
  has_many :legacy_pages

  validates :volume, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}, uniqueness: {scope: :volume, message: 'should be unique within a volume. '}

  default_scope { order('volume DESC, number DESC') }

  def name
    "Volume #{volume} Issue #{number}"
  end
end
