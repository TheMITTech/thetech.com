class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :roles, class_name: 'UserRole'

  def role_values
    roles.map(&:value).sort
  end

  def update_roles(new_roles)
    new_roles.select! { |role| UserRole::ROLE_TITLES.include? role }

    current_roles = role_values

    need_to_add = new_roles - current_roles
    need_to_remove = current_roles - new_roles

    roles.where(value: need_to_remove).delete_all
    need_to_add.each do |role|
      roles.create value: role
    end
  end
end
