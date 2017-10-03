class Ad < ActiveRecord::Base
  # NEVER remove entries from these enums.
  # ALWAYS add new entries at the end.
  # MARK obselete entries in the POSITION_IS_OBSELETE array.
  enum position: {
    homepage_top:     0,
    homepage_section: 1,    # Obselete
    homepage_bottom:  2,
    piece_sidebar:    3,
    homepage_opinion: 4,    # Obselete
    homepage_arts:    5,
    homepage_sports:  6,
    homepage_news:    7,
  }

  POSITION_IS_OBSELETE = {
    "homepage_top" => false,
    "homepage_bottom" => false,
    "homepage_section" => true,
    "homepage_opinion" => true,
    "homepage_news" => false,
    "homepage_arts" => false,
    "homepage_sports" => false,
    "piece_sidebar" => false,
  }

  POSITION_WIDTHS = {
    "homepage_top" => (1100..1300),
    "homepage_bottom" => (1100..1300),
    "homepage_section" => (500..600),
    "homepage_opinion" => (500..600),
    "homepage_news" => (500..600),
    "homepage_arts" => (500..600),
    "homepage_sports" => (500..600),
    "piece_sidebar" => (150..200),
  }

  POSITION_HEIGHTS = {
    "homepage_top" => (50..150),
    "homepage_bottom" => (50..150),
    "homepage_section" => (80..120),
    "homepage_opinion" => (80..120),
    "homepage_news" => (80..120),
    "homepage_arts" => (80..120),
    "homepage_sports" => (80..120),
    "piece_sidebar" => (400..800),
  }

  POSITION_NAMES = {
    "homepage_top" => "Top Leaderboard (Platinum)",
    "homepage_bottom" => "Bottom Leaderboard (Gold)",
    "homepage_section" => "Side Rectangle (Silver)",
    "homepage_opinion" => "Homepage Opinion Section Rectangle (Silver)",
    "homepage_news" => "Homepage News Section Rectangle (Silver)",
    "homepage_arts" => "Homepage Arts Section Rectangle (Silver)",
    "homepage_sports" => "Homepage Sports Section Rectangle (Silver)",
    "piece_sidebar" => "Article Rectangle (Bronze)",
  }

  POSITION_SHORT_NAMES = {
    "homepage_top" => "Platinum",
    "homepage_bottom" => "Gold",
    "homepage_news" => "Silver",
    "homepage_arts" => "Silver",
    "homepage_sports" => "Silver",
    "piece_sidebar" => "Bronze",
  }

  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }

  has_attached_file :content
  before_save :extract_dimensions, :normalize_link
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
    self.dimensions[0] rescue nil
  end

  def height
    self.dimensions[1] rescue nil
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

  def self.has_homepage_ad_for_section?(section)
    Ad.active.select { |a| a.position.to_sym == "homepage_#{section.name.downcase}".to_sym }.any?
  end

  def self.available_positions(current_position)
    Ad.positions.select { |p| (!Ad::POSITION_IS_OBSELETE[p]) || (current_position == p) }
  end

  private
    def extract_dimensions
      tempfile = content.queued_for_write[:original]
      unless tempfile.nil?
        geometry = Paperclip::Geometry.from_file(tempfile)
        self.dimensions = [geometry.width.to_i, geometry.height.to_i]
      end
    end

    def normalize_link
      return unless self.link.present?

      unless (self.link =~ /http:\/\// || self.link =~ /https:\/\//)
        self.link = "http://" + self.link
      end
    end
end
