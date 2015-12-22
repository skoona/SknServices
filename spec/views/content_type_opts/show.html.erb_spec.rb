require 'rails_helper'

RSpec.describe "content_type_opts/show", type: :view do
  before(:each) do
    @content_type_opt = assign(:content_type_opt, ContentTypeOpt.create!(
      :value => "Value",
      :description => "Description",
      :content_type => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Value/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(//)
  end
end
