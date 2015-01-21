FactoryGirl.define do
  factory :issue do
    volume 1
    sequence(:number) {|n| n }
  end
end
