class Piece < ActiveRecord::Base
  has_and_belongs_to_many :images
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :series
end
