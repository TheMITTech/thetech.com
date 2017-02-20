class Issue < AbstractModel
  has_many :pieces
  has_many :legacy_pages

  has_many :images

  has_attached_file :pdf
  has_attached_file :pdf_preview, :styles => {
    :medium => "600x600>"
  }

  validates :volume, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :number, presence: true, numericality: {only_integer: true, greater_than: 0}, uniqueness: {scope: :volume, message: 'should be unique within a volume. '}
  validates :published_at, presence: true
  validates_attachment :pdf, :content_type => { :content_type => %w(application/pdf) }
  validates_attachment_content_type :pdf_preview, :content_type => /\Aimage\/.*\Z/

  default_scope { order('published_at DESC') }

  scope :published, -> { where('published_at <= ?', Time.now) }

  # Returns an array of articles associated with this issue.
  def articles
    self.pieces.select { |p| !p.article.nil? }.map(&:article)
  end

  def pieces_with_published_articles
    self.pieces.with_published_article
  end

  def pieces_with_articles
    self.pieces.with_article
  end

  # Returns a user-friendly string representation of the name of this issue.
  def name
    "Volume #{volume} Issue #{number}"
  end

  # Return the issues grouped by volumes
  def self.volumes
    self.all.group_by(&:volume)
  end

  def self.latest_published
    Issue.published.first
  end

  def published_at=(date)
     begin
       parsed = Date.strptime(date,'%m/%d/%Y')
       super parsed
     rescue
       super date
     end
  end

  def generate_pdf_preview!
    if self.pdf.exists?
      require 'rmagick'
      require 'open-uri'

      tmp_pdf_file = '/tmp/pdf_preview.pdf'
      tmp_png_file = '/tmp/pdf_preview.png'

      tmp_pdf = File.open(tmp_pdf_file, 'wb')
      tmp_pdf.write(Paperclip.io_adapters.for(self.pdf).read)
      tmp_pdf.close

      im = Magick::ImageList.new(tmp_pdf_file)
      im[0].write tmp_png_file

      self.pdf_preview = File.open(tmp_png_file)
      self.save
    else
      raise "Couldn't finish generate_pdf_preview"
    end
  end
end
