require 'rails_helper'

RSpec.describe "profile_types/new", type: :view do
  before(:each) do
    assign(:profile_type, ProfileType.new(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new profile_type form" do
    render

    assert_select "form[action=?][method=?]", profile_types_path, "post" do

      assert_select "input#profile_type_name[name=?]", "profile_type[name]"

      assert_select "input#profile_type_description[name=?]", "profile_type[description]"
    end
  end
end
