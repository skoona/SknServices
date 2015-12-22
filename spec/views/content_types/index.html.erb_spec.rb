require 'rails_helper'

RSpec.describe "content_types/index", type: :view do
  before(:each) do
    assign(:content_types, [
      ContentType.create!(
        :name => "Name",
        :description => "Description",
        :value_data_type => "Value Data Type"
      ),
      ContentType.create!(
        :name => "Name",
        :description => "Description",
        :value_data_type => "Value Data Type"
      )
    ])
  end

  it "renders a list of content_types" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Value Data Type".to_s, :count => 2
  end
end
