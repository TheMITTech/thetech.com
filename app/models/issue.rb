class Issue < AbstractModel
  has_many :legacy_pages

  has_many :articles, dependent: :destroy
  has_many :images, dependent: :destroy

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

  # Returns a user-friendly string representation of the name of this issue.
  def name
    "Volume #{volume} Issue #{number}"
  end

  def short_name
    "V#{volume} N#{number}"
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
    return unless self.pdf.exists?

    begin
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
    rescue Exception
    end
  end

  def as_react(ability)
    (self.as_json only: [:id]).merge({
      short_name: self.short_name
    })
  end

  # TODO: Created specifically for _article_select.html.erb
  # Would rather not have
  def published_articles
    self.articles.web_published
  end
end
