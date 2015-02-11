require_relative '../rails_helper'
require_relative '../support/api_helper'
RSpec.configure do |c|
  c.include ApiHelper
end

describe ApiController do
  describe 'GET #article_parts' do
    it 'returns a nonempty array of strings' do
      get :article_parts
      res = JSON.parse(get_response_data(response))['parts']

      expect_checksum_to_be_correct(response)
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
      res = JSON.parse(get_response_data(response))

      expect_checksum_to_be_correct(response)
      expect(res['issue']).to equal(1)
      expect(res['volume']).to equal(2)
    end
  end

  describe 'GET #issue_lookup' do
    let(:issue) { create(:issue, volume: 1, number: 1) }
    let(:other_issue) { create(:issue, volume: 2, number: 3) }
    let(:pieces) { create_list(:article_piece, 10, issue: issue) }
    let(:piece_ready_for_print) { create(:article_piece, issue: issue) }
    let(:other_piece) { create(:article_piece, issue: other_issue) }

    before do
      # create the articles (force them to be evaluated before the test)
      pieces.each { |p| p.article.latest_version.print_draft! }
      piece_ready_for_print.article.latest_version.print_ready!
    end

    it 'returns the article list' do
      get :issue_lookup, volume: 1, issue: 1
      res = JSON.parse(get_response_data(response))

      expect_checksum_to_be_correct(response)
      expect(res['id']).to equal(issue.id)
      expect(res['number']).to equal(issue.number)
      expect(res['volume']).to equal(issue.volume)
      expect(res['articles']).to_not be_empty
      expect(res['articles'].first.keys)
        .to include('id', 'headline', 'section', 'slug', 'ready_for_print')
      expect(res['articles'].map { |e| e['id'] }.sort)
        .to eq(pieces.map(&:article).map(&:id)
                     .push(piece_ready_for_print.article.id).sort)
      expect(res['articles'].select { |e| !e['ready_for_print'] }.length)
        .to eq(pieces.length)
      expect(res['articles'].select { |e| e['ready_for_print'] }.length)
        .to eq(1)
    end
  end

  describe 'GET #article_as_xml' do
    it 'exports the article successfully' do
      # should probably come up with a better test in the future
      t = create(:article)
      get :article_as_xml, id: t.id

      expect_checksum_to_be_correct(response)
      expect(response.status).to eq(200)
      expect(response.body.length).to_not eq(0)
    end

    it 'escapes special characters' do
      t = create(:article, headline: 'Special < & > Yay')
      get :article_as_xml, id: t.id
      xml = JSON.parse(get_response_data(response))['xml']

      expect_checksum_to_be_correct(response)
      expect(response.status).to eq(200)
      expect(response.body.length).to_not eq(0)
      expect(xml).to include('Special &lt; &amp; &gt; Yay')
    end
  end
end
