require 'rails_helper'

RSpec.describe "content_profiles/edit", type: :view do
  before(:each) do
    @content_profile = assign(:content_profile, ContentProfile.create!(
      :person_authentication_key => "MyString",
      :profile_type => nil,
      :authentication_provider => "MyString",
      :username => "MyString",
      :display_name => "MyString",
      :email => "MyString"
    ))
  end

  it "renders the edit content_profile form" do
    render

    assert_select "form[action=?][method=?]", content_profile_path(@content_profile), "post" do

      assert_select "input#content_profile_person_authentication_key[name=?]", "content_profile[person_authentication_key]"

      assert_select "input#content_profile_profile_type_id[name=?]", "content_profile[profile_type_id]"

      assert_select "input#content_profile_authentication_provider[name=?]", "content_profile[authentication_provider]"

      assert_select "input#content_profile_username[name=?]", "content_profile[username]"

      assert_select "input#content_profile_display_name[name=?]", "content_profile[display_name]"

      assert_select "input#content_profile_email[name=?]", "content_profile[email]"
    end
  end
end
