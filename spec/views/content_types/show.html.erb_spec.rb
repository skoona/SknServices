require 'rails_helper'

RSpec.describe "content_types/show", type: :view do
  before(:each) do
    @content_type = assign(:content_type, ContentType.create!(
      :name => "Name",
      :description => "Description",
      :value_data_type => "Value Data Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Value Data Type/)
  end
end
