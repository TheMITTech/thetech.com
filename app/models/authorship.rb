class Authorship < ActiveRecord::Base
  belongs_to :draft
  belongs_to :author
end
