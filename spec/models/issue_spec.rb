require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe Issue do 

  context '#articles' do
    it 'returns associated articles' do
      article = create(:article)
      issue = create(:issue)
      piece = create(:piece)
      piece.article = article
      piece.issue = issue
      piece.save!

      expect(issue.articles).to eq([article])
    end
  end

  context '#name' do
    it 'correctly constructs a name' do
      issue = create(:issue)
      expect(issue.name).to eq("Volume #{issue.volume} Issue #{issue.number}")
    end
  end
end

