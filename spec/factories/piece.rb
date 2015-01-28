FactoryGirl.define do
  factory :piece do
    sequence(:slug) {|n| "slug-#{n}"}
    issue
    section
    image
  end

  factory :article_piece, class: Piece do
    sequence(:slug) { |n| "article-slug-#{n}" }
    issue
    section

    transient do
      article_headline "A piece with article"
    end

    after(:create) do |piece, evaluator|
      create(:article, piece_id: piece.id, headline: evaluator.article_headline)
    end
  end
end
