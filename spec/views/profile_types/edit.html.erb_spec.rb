require 'rails_helper'

RSpec.describe "profile_types/edit", type: :view do
  before(:each) do
    @profile_type = assign(:profile_type, ProfileType.create!(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit profile_type form" do
    render

    assert_select "form[action=?][method=?]", profile_type_path(@profile_type), "post" do

      assert_select "input#profile_type_name[name=?]", "profile_type[name]"

      assert_select "input#profile_type_description[name=?]", "profile_type[description]"
    end
  end
end
