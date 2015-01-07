class Article < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pieces

  validates :title, presence: true, length: {minimum: 2}
end
