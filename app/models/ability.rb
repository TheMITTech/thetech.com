class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage, :change_state, to: everything

    user ||= User.new
    roles = user.roles.map(&:value)

    can :read, :all

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
    can :everything, Article { |a| user.articles.include?(a) }
    can :create, Article

    can :everything, Image { |a| user.images.include?(a) }
    can :create, Image
  end

  def setup_editor_privileges(roles)
    return unless roles.include? UserRole::EDITOR
    can :everything, Series
    can :everything, Piece
    can :everything, Article
    can :everything, Image
  end
end
