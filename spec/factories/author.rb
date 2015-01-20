FactoryGirl.define do
  factory :author do
    name "John Doe"
  end

  factory :author_one_name, class: Author do
    name "Jane"
  end
end
