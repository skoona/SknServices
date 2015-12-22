require 'rails_helper'

RSpec.describe "user_roles/edit", type: :view do
  before(:each) do
    @user_role = assign(:user_role, UserRole.create!(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit user_role form" do
    render

    assert_select "form[action=?][method=?]", user_role_path(@user_role), "post" do

      assert_select "input#user_role_name[name=?]", "user_role[name]"

      assert_select "input#user_role_description[name=?]", "user_role[description]"
    end
  end
end
