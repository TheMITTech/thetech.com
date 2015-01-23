# Schema information
#
# table: images
#
# caption		text
# attribution		text
# created_at		datetime
# updated_at 		datetime

class Image < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pieces

  belongs_to :primary_piece, class_name: 'Piece'

  has_many :pictures

  validates :caption, presence: true, length: {minimum: 2}
end
