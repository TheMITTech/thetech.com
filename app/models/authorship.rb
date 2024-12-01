class Authorship < ApplicationRecord
  belongs_to :draft
  belongs_to :author
end
