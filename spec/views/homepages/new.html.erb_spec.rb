require 'rails_helper'

RSpec.describe "homepages/new", :type => :view do
  before(:each) do
    assign(:homepage, Homepage.new(
      :layout => "MyText"
    ))
  end

  it "renders new homepage form" do
    render

    assert_select "form[action=?][method=?]", homepages_path, "post" do

      assert_select "textarea#homepage_layout[name=?]", "homepage[layout]"
    end
  end
end
