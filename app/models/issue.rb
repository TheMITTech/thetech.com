class Issue < ActiveRecord::Base
  has_many :pieces
  has_many :legacy_pages

  has_attached_file :pdf


  validates :volume, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}, uniqueness: {scope: :volume, message: 'should be unique within a volume. '}
  validates_attachment :pdf, :content_type => { :content_type => %w(application/pdf) }


  default_scope { order('volume DESC, number DESC') }

  def articles
    self.pieces.select { |p| !p.article.nil? }.map(&:article)
  end

  def name
    "Volume #{volume} Issue #{number}"
  end
end
