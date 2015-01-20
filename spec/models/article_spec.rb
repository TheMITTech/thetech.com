require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe Article, '#author_ids' do
  it 'correctly returns author ids' do
    # setup
    article = create(:article)
    author1 = create(:author, article_id: article.id)
    author2 = create(:author_one_name, article_id: article.id)
    expect(article.author_ids).to eq '1,2'
  end
end

