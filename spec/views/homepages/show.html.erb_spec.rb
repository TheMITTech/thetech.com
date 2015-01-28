require 'rails_helper'

RSpec.describe "homepages/show", :type => :view do
  before(:each) do
    @homepage = assign(:homepage, Homepage.create!(
      :layout => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
  end
end
