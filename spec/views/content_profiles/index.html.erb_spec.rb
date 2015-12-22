require 'rails_helper'

RSpec.describe "content_profiles/index", type: :view do
  before(:each) do
    assign(:content_profiles, [
      ContentProfile.create!(
        :person_authentication_key => "Person Authentication Key",
        :profile_type => nil,
        :authentication_provider => "Authentication Provider",
        :username => "Username",
        :display_name => "Display Name",
        :email => "Email"
      ),
      ContentProfile.create!(
        :person_authentication_key => "Person Authentication Key",
        :profile_type => nil,
        :authentication_provider => "Authentication Provider",
        :username => "Username",
        :display_name => "Display Name",
        :email => "Email"
      )
    ])
  end

  it "renders a list of content_profiles" do
    render
    assert_select "tr>td", :text => "Person Authentication Key".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Authentication Provider".to_s, :count => 2
    assert_select "tr>td", :text => "Username".to_s, :count => 2
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
  end
end
