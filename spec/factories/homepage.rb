FactoryGirl.define do
  factory :homepage_draft, class: Homepage  do
    status 0
    layout []
  end

  factory :homepage_published, class: Homepage  do
    status 2
    layout []
  end
end
