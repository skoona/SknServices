require 'rails_helper'

RSpec.describe "user_group_roles/show", type: :view do
  before(:each) do
    @user_group_role = assign(:user_group_role, UserGroupRole.create!(
      :name => "Name",
      :description => "Description",
      :group_type => "Group Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Group Type/)
  end
end
