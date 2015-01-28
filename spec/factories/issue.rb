FactoryGirl.define do
  factory :issue do
    volume 1
    sequence(:number) { |n| n }
    published_at Time.now.to_date
  end
end
