class Issue < ActiveRecord::Base
  has_many :pieces

  def name
    "Volume #{volume} Issue #{number}"
  end
end
