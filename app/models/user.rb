class User < AbstractModel
  ROLE_TITLES = {
    admin: 'Admin',
    chairman: 'Chairman',
    editor_in_chief: 'Editor in Chief',
    content_editor: 'Editor',
    content_staff: 'Staff',
    business_staff: 'Business',
    production_staff: 'Production Staff',
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :article_versions
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :images

  serialize :roles

  has_many :legacy_roles, class_name: 'UserRole'

  before_create :set_default_roles

  private
    def set_default_roles
      self.roles = []
    end
end
