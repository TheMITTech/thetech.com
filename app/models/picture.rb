class Picture < AbstractModel
  has_attached_file :content, :styles => {
    :square => "300x300#",
    :thumbnail => "150",
    :large => "800x800>",
    :medium => "400x400>"
  }, :default_url => "/image/:style/default.gif"

  belongs_to :image, class_name: 'PreRebirthImage', foreign_key: 'image_id'

  validates_attachment_content_type :content, :content_type => /\Aimage\/.*\Z/
  validates :content, presence: true
end
