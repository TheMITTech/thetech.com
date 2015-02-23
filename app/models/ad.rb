class Ad < ActiveRecord::Base
  enum position: [:homepage_top]

  POSITION_WIDTHS = {
    "homepage_top" => (1100..1300)
  }

  POSITION_HEIGHTS = {
    "homepage_top" => (50..150)
  }

  POSITION_NAMES = {
    "homepage_top" => "Homepage top banner"
  }

  POSITION_SHORT_NAMES = {
    "homepage_top" => "Homepage Top"
  }

  has_attached_file :content
  before_save :extract_dimensions
  serialize :dimensions
  validates_attachment_content_type :content, content_type: /\Aimage\/.*\Z/

  validates :name, presence: true, length: {minimum: 5}
  validates :start_date, presence: true
  validates :end_date, presence: true

  def active?
    (self.start_date <= Date.today) && (Date.today <= self.end_date)
  end

  def start_date=(date)
     begin
       parsed = Date.strptime(date,'%m/%d/%Y')
       super parsed
     rescue
       super date
     end
  end

  def end_date=(date)
     begin
       parsed = Date.strptime(date,'%m/%d/%Y')
       super parsed
     rescue
       super date
     end
  end

  def duration
    (self.end_date - self.start_date).to_i + 1
  end

  def recommended_width_range
    Ad::POSITION_WIDTHS[self.position]
  end

  def recommended_height_range
    Ad::POSITION_HEIGHTS[self.position]
  end

  def width
    self.dimensions[0]
  end

  def height
    self.dimensions[1]
  end

  def has_recommended_width?
    self.recommended_width_range.include?(self.width)
  end

  def has_recommended_height?
    self.recommended_height_range.include?(self.height)
  end

  def has_recommended_dimensions?
    self.has_recommended_width? && self.has_recommended_height?
  end

  private
    def extract_dimensions
      tempfile = content.queued_for_write[:original]
      unless tempfile.nil?
        geometry = Paperclip::Geometry.from_file(tempfile)
        self.dimensions = [geometry.width.to_i, geometry.height.to_i]
      end
    end
end
