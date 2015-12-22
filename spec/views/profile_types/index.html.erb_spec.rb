require 'rails_helper'

RSpec.describe "profile_types/index", type: :view do
  before(:each) do
    assign(:profile_types, [
      ProfileType.create!(
        :name => "Name",
        :description => "Description"
      ),
      ProfileType.create!(
        :name => "Name",
        :description => "Description"
      )
    ])
  end

  it "renders a list of profile_types" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
