class Ad < ActiveRecord::Base
  enum position: [:homepage_top]

  POSITION_WIDTHS = {
    "homepage_top" => (1100..1300)
  }

  POSITION_NAMES = {
    "homepage_top" => "Homepage top banner"
  }

  POSITION_SHORT_NAMES = {
    "homepage_top" => "Homepage Top"
  }

  has_attached_file :content
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
end
