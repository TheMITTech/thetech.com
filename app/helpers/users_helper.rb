module UsersHelper
  def role_checkboxes(user)
    vals = user.role_values

    code = label_tag('user[roles]', 'Roles')

    UserRole::ROLE_TITLES.each do |role, title|
      checked = vals.include?(role)
      code << check_box_tag("user[roles][#{role}]", 1, checked) << title
    end

    code.html_safe
  end
end
