require 'rails_helper'

RSpec.describe "article_lists/show", :type => :view do
  before(:each) do
    @article_list = assign(:article_list, ArticleList.create!(
      :name => "MyText",
      :piece_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
