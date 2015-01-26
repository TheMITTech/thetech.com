require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe Piece do

  context '#primary_tag' do
    it 'correctly updates primary tag' do
      piece = create(:piece)
      tag = 'primary_tag'
      piece.primary_tag = tag
      expect(piece.primary_tag).to eq(tag)
    end

    it 'returns nil when no primary tag' do
      piece = create(:piece)
      expect(piece.primary_tag).to eq(nil)
    end
  end

  context '#name' do
    it 'correctly constructs a name if article exists' do
      article = create(:article)
      piece = create(:piece)
      piece.article = article
      piece.save!
      expect(piece.name).to eq(article.headline)
    end
  end
end

