require 'rails_helper'

RSpec.describe "content_profile_entries/edit", type: :view do
  before(:each) do
    @content_profile_entry = assign(:content_profile_entry, ContentProfileEntry.create!(
      :topic_value => "MyString",
      :content_value => "MyString",
      :content_type => nil,
      :topic_type => nil,
      :content_profile => nil
    ))
  end

  it "renders the edit content_profile_entry form" do
    render

    assert_select "form[action=?][method=?]", content_profile_entry_path(@content_profile_entry), "post" do

      assert_select "input#content_profile_entry_topic_value[name=?]", "content_profile_entry[topic_value]"

      assert_select "input#content_profile_entry_content_value[name=?]", "content_profile_entry[content_value]"

      assert_select "input#content_profile_entry_content_type_id[name=?]", "content_profile_entry[content_type_id]"

      assert_select "input#content_profile_entry_topic_type_id[name=?]", "content_profile_entry[topic_type_id]"

      assert_select "input#content_profile_entry_content_profile_id[name=?]", "content_profile_entry[content_profile_id]"
    end
  end
end
