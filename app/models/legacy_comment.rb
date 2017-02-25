class LegacyComment < ActiveRecord::Base
  belongs_to :legacy_commentable

  default_scope { order('published_at ASC') }

  scope :published, -> { where('published_at is not null') }
end
