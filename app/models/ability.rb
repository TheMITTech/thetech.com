##
# This class defines the abilities and privileges belonging to the various
# user roles.
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    roles = user.roles || []

    if !roles.empty?
      # Anyone can read anything
      can :read, :all
    end

    if roles.include? :admin or
       roles.include? :chairman
      can :manage, :all
    end

    if roles.include? :staff or
      roles.include? :content_staff or
       roles.include? :content_editor or
       roles.include? :editor_in_chief or
       roles.include? :production_staff
      can [:create, :update], [Article, Draft, Image, Homepage]
      can [:add_article, :remove_article], Image
      can :duplicate, Homepage
    end

    if roles.include? :production_staff
      can [:upload_pdf, :upload_pdf_form], [Issue]
    end

    if roles.include? :content_editor or
       roles.include? :editor_in_chief
      can :ready, [Article, Draft, Image, Homepage]
      can :update_rank, [Article]
    end

    if roles.include? :editor_in_chief
      can :publish, [Article, Draft, Image, Homepage]
      can :manage, Issue
    end

    if roles.include? :business_staff
      can :manage, :ads
    end

  end
end
