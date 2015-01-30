class Picture < AbstractModel
  has_attached_file :content, :styles => {
    :thumbnail => "150",
    :large => "800x800>",
    :medium => "400x400>"
  }, :default_url => "/image/:style/default.gif"

  belongs_to :image

  validates_attachment_content_type :content, :content_type => /\Aimage\/.*\Z/
  validates :content, presence: true
end
