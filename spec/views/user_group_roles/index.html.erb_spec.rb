require 'rails_helper'

RSpec.describe "user_group_roles/index", type: :view do
  before(:each) do
    assign(:user_group_roles, [
      UserGroupRole.create!(
        :name => "Name",
        :description => "Description",
        :group_type => "Group Type"
      ),
      UserGroupRole.create!(
        :name => "Name",
        :description => "Description",
        :group_type => "Group Type"
      )
    ])
  end

  it "renders a list of user_group_roles" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Group Type".to_s, :count => 2
  end
end
