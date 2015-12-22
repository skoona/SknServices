require 'rails_helper'

RSpec.describe "user_roles/new", type: :view do
  before(:each) do
    assign(:user_role, UserRole.new(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new user_role form" do
    render

    assert_select "form[action=?][method=?]", user_roles_path, "post" do

      assert_select "input#user_role_name[name=?]", "user_role[name]"

      assert_select "input#user_role_description[name=?]", "user_role[description]"
    end
  end
end
