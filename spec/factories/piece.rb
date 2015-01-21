FactoryGirl.define do
  factory :piece do
    sequence(:slug) {|n| "slug-#{n}"}
    issue
    section
  end
end
