require 'rails_helper'

RSpec.describe "profile_types/show", type: :view do
  before(:each) do
    @profile_type = assign(:profile_type, ProfileType.create!(
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
