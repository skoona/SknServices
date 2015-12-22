require 'rails_helper'

RSpec.describe "content_profile_entries/show", type: :view do
  before(:each) do
    @content_profile_entry = assign(:content_profile_entry, ContentProfileEntry.create!(
      :topic_value => "Topic Value",
      :content_value => "Content Value",
      :content_type => nil,
      :topic_type => nil,
      :content_profile => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Topic Value/)
    expect(rendered).to match(/Content Value/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
