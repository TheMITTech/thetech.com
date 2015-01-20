class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage, :change_state, to: :everything

    user ||= User.new
    roles = user.roles.map(&:value)

    grant_generic_privileges(roles)
    grant_create_issue_privileges(roles)
    grant_pdf_privileges(roles)
    grant_publishing_privileges(roles)
    grant_edit_user_role_privileges(roles)
    grant_admin_privileges(roles)
  end

  def grant_generic_privileges(roles)
    return if (roles & [
      UserRole::ADMIN,
      UserRole::PUBLISHER,
      UserRole::EDITOR_IN_CHIEF,
      UserRole::PRODUCTION,
      UserRole::NEWS_EDITOR,
      UserRole::OPINION_EDITOR,
      UserRole::CAMPUS_LIFE_EDITOR,
      UserRole::ARTS_EDITOR,
      UserRole::SPORTS_EDITOR,
      UserRole::PHOTO_EDITOR,
      UserRole::ONLINE_MEDIA_EDITOR,
      UserRole::STAFF,
      UserRole::BUSINESS
    ]).empty?

    can [:index, :show, :edit, :new, :create, :update, :assets_list, :as_xml],
        Article
    can [:index, :show, :revert], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
         :unassign_piece], Image
    can [:index, :lookup], Issue
    can [:index], Section
    can [:index, :show], User
  end

  def grant_create_issue_privileges(roles)
    return if (roles & [
      UserRole::ADMIN,
      UserRole::PUBLISHER,
      UserRole::EDITOR_IN_CHIEF,
      UserRole::PRODUCTION,
      UserRole::NEWS_EDITOR,
      UserRole::OPINION_EDITOR,
      UserRole::CAMPUS_LIFE_EDITOR,
      UserRole::ARTS_EDITOR,
      UserRole::SPORTS_EDITOR,
      UserRole::PHOTO_EDITOR,
      UserRole::ONLINE_MEDIA_EDITOR
    ]).empty?

    can [:create], Issue
  end

  def grant_pdf_privileges(roles)
    return if (roles & [
      UserRole::ADMIN,
      UserRole::PUBLISHER,
      UserRole::EDITOR_IN_CHIEF,
      UserRole::PRODUCTION
    ]).empty?

    can [:upload_pdf, :remove_pdf], Issue
  end

  def grant_publishing_privileges(roles)
    return if (roles & [
      UserRole::ADMIN,
      UserRole::PUBLISHER,
      UserRole::EDITOR_IN_CHIEF
    ]).empty?

    can [:publish], ArticleVersion
  end

  def grant_edit_user_role_privileges(roles)
    return if (roles & [
      UserRole::ADMIN,
      UserRole::EDITOR_IN_CHIEF
    ]).empty?

    can [:edit, :update], User do |u|
      not(u.roles.map(&:value).include? UserRole::ADMIN)
    end
  end

  def grant_admin_privileges(roles)
    return unless roles.include? UserRole::ADMIN
    can :everything, :all
  end
end
