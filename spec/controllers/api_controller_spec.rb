require_relative '../rails_helper'
describe ApiController do
  describe 'GET #article_parts' do
    it 'returns a nonempty array of strings' do
      get :article_parts
      res = JSON.parse(response.body)['parts']
      expect(res.length).to_not equal(0)
      expect(res).to all(be_a(String))
    end
  end

  describe 'GET #newest_issue' do
    before do
      create(:issue, volume: 1, number: 1)
      create(:issue, volume: 1, number: 2)
      create(:issue, volume: 2, number: 1)
    end

    it 'returns the newest issue' do
      get :newest_issue
      res = JSON.parse(response.body)
      expect(res['issue']).to equal(1)
      expect(res['volume']).to equal(2)
    end
  end

  describe 'GET #issue_lookup' do
    let(:issue) { create(:issue, volume: 1, number: 1) }
    let(:other_issue) { create(:issue, volume: 2, number: 3) }
    let(:articles) { create_list(:article_piece, 10, issue: issue) }
    let(:other_article) { create(:article_piece, issue: other_issue) }

    before do
      # create the articles (force them to be evaluated before the test)
      articles
    end

    it 'returns the article list' do
      get :issue_lookup, volume: 1, issue: 1
      res = JSON.parse(response.body)
      expect(res['id']).to equal(issue.id)
      expect(res['number']).to equal(issue.number)
      expect(res['volume']).to equal(issue.volume)
      expect(res['articles']).to_not be_empty
      expect(res['articles'].first.keys).to include('id', 'headline', 'section', 'slug')
      expect(res['articles'].map{|e| e['id']}.sort).to eq(articles.map(&:id).sort)
    end
  end

  describe 'GET #article_as_xml' do
    it 'exports the article successfully' do
      # should probably come up with a better test in the future
      t = create(:article)
      get :article_as_xml, id: t.id
      expect(response.status).to eq(200)
      expect(response.body.length).to_not eq(0)
    end
  end
end
