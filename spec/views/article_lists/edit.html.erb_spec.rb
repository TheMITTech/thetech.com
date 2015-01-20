require 'rails_helper'

RSpec.describe "article_lists/edit", :type => :view do
  before(:each) do
    @article_list = assign(:article_list, ArticleList.create!(
      :name => "MyText",
      :piece_id => 1
    ))
  end

  it "renders the edit article_list form" do
    render

    assert_select "form[action=?][method=?]", article_list_path(@article_list), "post" do

      assert_select "textarea#article_list_name[name=?]", "article_list[name]"

      assert_select "input#article_list_piece_id[name=?]", "article_list[piece_id]"
    end
  end
end
