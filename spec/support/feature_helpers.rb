##
#
# Ref: https://github.com/railsware/rack_session_access
#
# page.set_rack_session to set your desired session data
# page.get_rack_session to obtain your application session data
# page.get_rack_session_key to obtain certain key if your application session data
#
##
# EXAMPLE
#
# feature "My feature" do
#   given!(:user) { create(:user, email: 'jack@daniels.com') }
#
#   scenario "logged in user access profile page" do
#     page.set_rack_session(user_id: user.id)
#     visit "/profile"
#     expect(page).to have_content("Hi, jack@daniels.com")
#   end
#
#   scenario "visit landing page" do
#     visit "/landing?ref=123"
#     expect(page.get_rack_session_key('ref')).to eq("123")
#   end
# end
##
#
# feature 'User dashboard', type: :feature do
#   given(:user) { create(:user) }
#   background do
#     logged_as user
#   end
#   scenario 'User reviews a dashboard' do
#     ...
#   end
# end




module FeatureHelpers
  def logged_as(user)
    page.set_rack_session('warden.user.access_profile.key' => [Secure::UserProfile.class.name, user.person_authenticated_key])
    # "warden.user.access_profile.key" => [Secure::UserProfile.class.name, user.person_authenticated_key]
  end
  def click_signout_link
    Capybara.current_session.driver.delete signout_url
  end
end