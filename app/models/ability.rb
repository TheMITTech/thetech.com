class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage, :change_state, to: :everything

    user ||= User.new
    roles = user.roles.map(&:value)

    setup_admin_privileges(roles)
    setup_writer_privileges(roles)
    setup_editor_privileges(roles)
  end

  def setup_admin_privileges(roles)
    return unless roles.include? UserRole::ADMIN
    can :everything, :all
  end

  def setup_writer_privileges(roles)
    return unless roles.include? UserRole::WRITER
    can [:index, :show, :edit, :new, :create, :update, :as_xml, :assets_list],
        Article
    can [:index, :show, :revert], ArticleVersion
    can [:index, :show], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
         :unassign_piece], Image
    can [:index], Issue
    can [:index], Section
  end

  def setup_editor_privileges(roles)
    return unless roles.include? UserRole::EDITOR
    can [:index, :show, :edit, :new, :create, :update, :as_xml, :assets_list],
        Article
    can [:index, :show, :revert, :publish], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
      :unassign_piece], Image
    can [:index, :create, :lookup, :upload_pdf_form, :upload_pdf], Issue
    can [:index], Section
  end
end
