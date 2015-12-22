require 'rails_helper'

RSpec.describe "user_group_roles/new", type: :view do
  before(:each) do
    assign(:user_group_role, UserGroupRole.new(
      :name => "MyString",
      :description => "MyString",
      :group_type => "MyString"
    ))
  end

  it "renders new user_group_role form" do
    render

    assert_select "form[action=?][method=?]", user_group_roles_path, "post" do

      assert_select "input#user_group_role_name[name=?]", "user_group_role[name]"

      assert_select "input#user_group_role_description[name=?]", "user_group_role[description]"

      assert_select "input#user_group_role_group_type[name=?]", "user_group_role[group_type]"
    end
  end
end
