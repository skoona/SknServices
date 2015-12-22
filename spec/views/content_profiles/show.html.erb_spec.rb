require 'rails_helper'

RSpec.describe "content_profiles/show", type: :view do
  before(:each) do
    @content_profile = assign(:content_profile, ContentProfile.create!(
      :person_authentication_key => "Person Authentication Key",
      :profile_type => nil,
      :authentication_provider => "Authentication Provider",
      :username => "Username",
      :display_name => "Display Name",
      :email => "Email"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Person Authentication Key/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Authentication Provider/)
    expect(rendered).to match(/Username/)
    expect(rendered).to match(/Display Name/)
    expect(rendered).to match(/Email/)
  end
end
