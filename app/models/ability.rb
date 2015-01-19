class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage, :change_state, to: :everything

    user ||= User.new
    roles = user.roles.map(&:value)

    setup_admin_privileges(roles)
    setup_executive_privileges(roles)
    setup_production_privileges(roles)
    setup_editor_privileges(roles)
    setup_generic_privileges(roles)
  end

  def setup_admin_privileges(roles)
    return unless roles.include? UserRole::ADMIN
    can :everything, :all
  end

  def setup_executive_privileges(roles)
    return unless roles.any? { |role|
      [ UserRole::PUBLISHER, UserRole::EDITOR_IN_CHIEF ].include? role
    }
    can [:index, :show, :edit, :new, :create, :update, :as_xml, :assets_list],
    Article
    can [:index, :show, :revert, :publish], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
      :unassign_piece], Image
    can [:index, :create, :lookup], Issue
    can [:index], Section
    can [:index, :show, :create, :edit, :update], User
  end

  def setup_production_privileges(roles)
    return unless roles.include? UserRole::PRODUCTION
    can [:index, :show, :edit, :new, :create, :update, :as_xml, :assets_list],
    Article
    can [:index, :show, :revert], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
      :unassign_piece], Image
    can [:index, :create, :lookup], Issue
    can [:index], Section
    can [:index, :show, :create], User
  end

  def setup_editor_privileges(roles)
    return unless roles.any? { |role|
      [
        UserRole::NEWS_EDITOR,
        UserRole::OPINION_EDITOR,
        UserRole::CAMPUS_LIFE_EDITOR,
        UserRole::ARTS_EDITOR,
        UserRole::SPORTS_EDITOR,
        UserRole::PHOTO_EDITOR,
        UserRole::ONLINE_MEDIA_EDITOR,
      ].include? role
    }
    can [:index, :show, :edit, :new, :create, :update, :assets_list], Article
    can [:index, :show, :revert], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
      :unassign_piece], Image
    can [:index, :create, :lookup], Issue
    can [:index], Section
    can [:index, :show, :create], User
  end

  def setup_generic_privileges(roles)
    return unless roles.any? { |role|
      [
        UserRole::STAFF,
        UserRole::BUSINESS,
        UserRole::PRE_STAFF
      ].include? role
    }
    can [:index, :show, :edit, :new, :create, :update, :assets_list], Article
    can [:index, :show, :revert], ArticleVersion
    can [:index, :show, :edit, :new, :create, :update], Author
    can [:index, :show, :edit, :new, :create, :update, :direct, :assign_piece,
      :unassign_piece], Image
    can [:index, :create, :lookup], Issue
    can [:index], Section
    can [:index, :show], User
  end
end
