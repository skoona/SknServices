require 'rails_helper'

RSpec.describe "user_roles/show", type: :view do
  before(:each) do
    @user_role = assign(:user_role, UserRole.create!(
      :name => "Name",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
  end
end
