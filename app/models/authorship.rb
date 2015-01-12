class Authorship < ActiveRecord::Base
  belongs_to :article
  belongs_to :author

  default_scope { order('rank ASC') }
end
