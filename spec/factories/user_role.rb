FactoryGirl.define do
  factory :writer_role, class: UserRole do
    value UserRole::WRITER
  end
  factory :editor_role, class: UserRole do
    value UserRole::EDITOR
  end
  factory :admin_role, class: UserRole do
    value UserRole::ADMIN
  end
end

