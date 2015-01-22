FactoryGirl.define do
  factory :user do
    name "John Doe"
    email "jdoe@mit.edu"
    password "password"
  end

  factory :admin, class: User do
    name "Admin"
    email "admin@mit.edu"
    password "admin_password"
    roles {[create(:admin_role)]}
  end
end
