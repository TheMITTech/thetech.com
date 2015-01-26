require 'rails_helper'

RSpec.describe "article_lists/index", :type => :view do
  before(:each) do
    assign(:article_lists, [
      ArticleList.create!(
        :name => "MyText",
        :piece_id => 1
      ),
      ArticleList.create!(
        :name => "MyText",
        :piece_id => 1
      )
    ])
  end

  it "renders a list of article_lists" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
