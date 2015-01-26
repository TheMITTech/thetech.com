FactoryGirl.define do
  factory :admin_role, class: UserRole do
    value UserRole::ADMIN
  end
  factory :publisher_role, class: UserRole do
    value UserRole::PUBLISHER
  end
  factory :editor_in_chief_role, class: UserRole do
    value UserRole::EDITOR_IN_CHIEF
  end
  factory :production_role, class: UserRole do
    value UserRole::PRODUCTION
  end
  factory :news_editor_role, class: UserRole do
    value UserRole::NEWS_EDITOR
  end
  factory :opinion_editor_role, class: UserRole do
    value UserRole::OPINION_EDITOR
  end
  factory :campus_life_editor_role, class: UserRole do
    value UserRole::CAMPUS_LIFE_EDITOR
  end
  factory :arts_editor_role, class: UserRole do
    value UserRole::ARTS_EDITOR
  end
  factory :sports_editor_role, class: UserRole do
    value UserRole::SPORTS_EDITOR
  end
  factory :photo_editor_role, class: UserRole do
    value UserRole::PHOTO_EDITOR
  end
  factory :online_media_editor_role, class: UserRole do
    value UserRole::ONLINE_MEDIA_EDITOR
  end
  factory :business_role, class: UserRole do
    value UserRole::BUSINESS
  end
  factory :staff_role, class: UserRole do
    value UserRole::STAFF
  end
end

