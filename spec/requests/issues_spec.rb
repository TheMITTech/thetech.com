require 'rails_helper'

RSpec.describe "Issues", :type => :request do
  sign_in_as_admin!

  describe "GET /admin/issues" do
    it "should list the issues" do
      FactoryGirl.create(:issue, volume: 123, number: 21)
      FactoryGirl.create(:issue, volume: 128, number: 35)

      visit issues_path
      expect(page).to have_content('123')
      expect(page).to have_content('21')
      # expect(page).to have_content('128')
      expect(page).to have_content('35')
    end

    it "should display PDF upload form upon clicking Upload", js: true do
      FactoryGirl.create(:issue)

      visit issues_path
      click_on 'Upload'

      expect(page).to have_css('input[name=content]')
    end

    it "should automatically upload PDF upon selecting", js: true do
      issue = FactoryGirl.create(:issue)

      visit issues_path
      click_on 'Upload'
      attach_file 'content', File.join(Rails.root, 'public/test/test.pdf')

      expect(page).to have_content("Successfully uploaded PDF")
    end

    it "should reject invalid PDF upload", js: true do
      issue = FactoryGirl.create(:issue)

      visit issues_path
      click_on 'Upload'
      attach_file 'content', File.join(Rails.root, 'public/test/test.png')

      expect(page).to have_content("Please make sure the file you upload is a valid PDF file.")
    end

    it "should allow user to remove existing PDF" do
      FactoryGirl.create(:issue, pdf: File.open(File.join(Rails.root, 'public/test/test.pdf')))

      visit issues_path

      expect(page).to have_content('View PDF')
      expect(page).to have_content('Remove PDF')

      click_on 'Remove PDF'

      expect(page).to have_content('Successfully removed PDF')
    end

    it "should allow user to view existing PDF" do
      FactoryGirl.create(:issue, pdf: File.open(File.join(Rails.root, 'public/test/test.pdf')))

      visit issues_path

      expect(page).to have_content('View PDF')
      expect(page).to have_content('Remove PDF')

      click_on 'View PDF'

      expect(page.response_headers['Content-Type']).to eq "application/pdf"
    end

    it "should allow user to create issue" do
      visit issues_path

      fill_in 'issue[volume]', with: '111'
      fill_in 'issue[number]', with: '28'
      fill_in 'issue[published_at]', with: '01/20/2014'
      click_on 'Create Issue'

      expect(page).to have_content('Successfully created issue. ')
    end

    it "should not allow empty fields" do
      visit issues_path

      click_on 'Create Issue'

      expect(page).to have_content('Volume can\'t be blank')
      expect(page).to have_content('Number can\'t be blank')
      expect(page).to have_content('Published at can\'t be blank')
    end

    it "should have link pointing to issue detail page" do
      FactoryGirl.create(:issue, volume: 100, number: 23)

      visit issues_path
      click_on 'Details'

      expect(page).to have_content('Volume 100 Issue 23')
    end

    it "should allow user to filter by volume", js: true do
      FactoryGirl.create(:issue, volume: 100, number: 23)
      FactoryGirl.create(:issue, volume: 110, number: 37)

      visit issues_path

      page.select 'Volume 100', from: 'filter_volume'

      expect(page).to have_css('td', text: '100')
      expect(page).to_not have_css('td', text: '110')

      expect(page).to have_content('Issues in Volume 100')
      expect(page).to have_css('option[selected]', 'Volume 100')
    end
  end

  describe "GET /admin/issues/:id" do
    let(:issue) { FactoryGirl.create(:issue, volume: 123, number: 25) }

    it "should contain the issue full name" do
      visit issue_path(issue)
      expect(page).to have_content("Volume 123 Issue 25")
    end

    it "should list article pieces belonging to the issue" do
      FactoryGirl.create(:article_piece, issue_id: issue.id, article_headline: 'Interesting Story')

      visit issue_path(issue)

      expect(page).to have_content("Interesting Story")
    end

    it "should allow changing article rankings", js: true do
      FactoryGirl.create(:article_piece, issue_id: issue.id, article_headline: 'Interesting Story')

      visit issue_path(issue)

      page.select '19', from: 'article_rank'

      expect(page).to have_content('Success')

      visit issue_path(issue)

      expect(page).to have_select('article_rank', selected: '19')
    end
  end
end
