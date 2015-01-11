class Issue < ActiveRecord::Base
  has_many :pieces

  validates :volume, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}, uniqueness: {scope: :volume, message: 'should be unique within a volume. '}

  def name
    "Volume #{volume} Issue #{number}"
  end
end
