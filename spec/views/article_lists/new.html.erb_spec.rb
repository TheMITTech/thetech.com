require 'rails_helper'

RSpec.describe "article_lists/new", :type => :view do
  before(:each) do
    assign(:article_list, ArticleList.new(
      :name => "MyText",
      :piece_id => 1
    ))
  end

  it "renders new article_list form" do
    render

    assert_select "form[action=?][method=?]", article_lists_path, "post" do

      assert_select "textarea#article_list_name[name=?]", "article_list[name]"

      assert_select "input#article_list_piece_id[name=?]", "article_list[piece_id]"
    end
  end
end
