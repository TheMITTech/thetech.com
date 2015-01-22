require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe Article, '#authors_line' do
  it 'correctly assembles authors line' do
    # setup
    article = create(:article)
    author1 = create(:author)
    author2 = create(:author_one_name)
    article.author_ids = "#{author1.id},#{author2.id}"
    article.save!
    expect(article.authors_line).to eq "#{author1.name} and #{author2.name}"
  end
end

