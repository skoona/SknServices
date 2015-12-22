require 'rails_helper'

RSpec.describe "content_profile_entries/index", type: :view do
  before(:each) do
    assign(:content_profile_entries, [
      ContentProfileEntry.create!(
        :topic_value => "Topic Value",
        :content_value => "Content Value",
        :content_type => nil,
        :topic_type => nil,
        :content_profile => nil
      ),
      ContentProfileEntry.create!(
        :topic_value => "Topic Value",
        :content_value => "Content Value",
        :content_type => nil,
        :topic_type => nil,
        :content_profile => nil
      )
    ])
  end

  it "renders a list of content_profile_entries" do
    render
    assert_select "tr>td", :text => "Topic Value".to_s, :count => 2
    assert_select "tr>td", :text => "Content Value".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
