require 'rails_helper'

RSpec.describe "homepages/index", :type => :view do
  before(:each) do
    assign(:homepages, [
      Homepage.create!(
        :layout => "MyText"
      ),
      Homepage.create!(
        :layout => "MyText"
      )
    ])
  end

  it "renders a list of homepages" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
