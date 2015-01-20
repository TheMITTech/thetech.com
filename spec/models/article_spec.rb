require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe Article, '#author_ids' do

  it 'correctly returns author ids' do
    # setup
    piece = Piece.create!
    article = Article.create!({headline: 'headline', piece_id: piece.id})
    author1 = Author.create!({article_id: article.id})
    author2 = Author.create!({article_id: article.id})
    expect(article.author_ids).to eq '1,2'
  end
end

