# spec/features/profile/profile_demo_process_spec.rb
#

RSpec.feature "Profile Demo Process.", {js: true} do
  given(:user) { page_user_eptester }

  context "ContentProfile Demo. " do

    scenario "Clicking profile loads Accessible table" do
      login_as(user)
      # visit signin_url
      # expect(current_path).to eq signin_path
      # fill_in 'Username', :with => "developer"
      # fill_in 'Password', :with => "developer99"
      # click_button 'Sign in'
      # expect(current_path).to eq home_pages_path

      visit in_action_admin_profiles_url
      expect(current_path).to eq in_action_admin_profiles_path

      # find('#users-table tbody tr').first.click
      expect(page).to have_css('#content-table tbody')
      # find('#content-table tbody tr').first.click
      # expect(page).to have_css('table.profile tbody tr.success')

      click_link "Sign out"
      expect(current_path).to eq home_pages_path
    end
  end

end
