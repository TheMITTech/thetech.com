FactoryGirl.define do
  factory :article do
    headline "headline"
    piece
    
    after(:create) do |a|
      a.save_version!
    end
  end
end

