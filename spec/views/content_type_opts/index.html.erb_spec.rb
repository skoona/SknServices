require 'rails_helper'

RSpec.describe "content_type_opts/index", type: :view do
  before(:each) do
    assign(:content_type_opts, [
      ContentTypeOpt.create!(
        :value => "Value",
        :description => "Description",
        :content_type => nil
      ),
      ContentTypeOpt.create!(
        :value => "Value",
        :description => "Description",
        :content_type => nil
      )
    ])
  end

  it "renders a list of content_type_opts" do
    render
    assert_select "tr>td", :text => "Value".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
