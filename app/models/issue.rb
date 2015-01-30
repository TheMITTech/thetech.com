class Issue < AbstractModel
  has_many :pieces
  has_many :legacy_pages

  has_attached_file :pdf

  validates :volume, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}, uniqueness: {scope: :volume, message: 'should be unique within a volume. '}
  validates :published_at, presence: true
  validates_attachment :pdf, :content_type => { :content_type => %w(application/pdf) }


  default_scope { order('volume DESC, number DESC') }

  # Returns an array of articles associated with this issue.
  def articles
    self.pieces.select { |p| !p.article.nil? }.map(&:article)
  end

  # Returns a user-friendly string representation of the name of this issue.
  def name
    "Volume #{volume} Issue #{number}"
  end

  # Return the issues grouped by volumes
  def self.volumes
    self.all.group_by(&:volume)
  end

  def published_at=(date)
     begin
       parsed = Date.strptime(date,'%m/%d/%Y')
       super parsed
     rescue
       super date
     end
  end
end
