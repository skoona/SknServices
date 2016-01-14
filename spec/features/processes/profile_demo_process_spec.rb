# spec/features/profile/profile_demo_process_spec.rb
#

RSpec.feature "Profile Demo Process.", {js: true} do
  given(:user) { user_eptester }

  context "AccessProfile Demo. " do
    background do
      login_as user
    end

    scenario "Clicking profile loads Accessible table" do
      # save_screenshot('AccessProfileDemoPageRSpec.png', :full => true)

      visit access_profile_demo_profiles_url
      expect(current_path).to eq access_profile_demo_profiles_path

      expect(page).to have_css('#access-table tbody')
      # find('#access-table tbody tr').click
      # expect(page).to have_css('table.profile tbody tr.success')

    end

  end

  context "ContentProfile Demo. " do

    scenario "Clicking profile loads Accessible table" do
      visit signin_url
      expect(current_path).to eq signin_path
      fill_in 'Username', :with => "developer"
      fill_in 'Password', :with => "developer99"
      click_button 'Sign in'
      expect(current_path).to eq home_pages_path

      visit content_profile_demo_profiles_url
      expect(current_path).to eq content_profile_demo_profiles_path

      expect(page).to have_css('#content-table tbody')
      # find('#access-table tbody tr').click
      # expect(page).to have_css('table.profile tbody tr.success')

      # click_signout_link
      # expect(current_path).to eq home_pages_path
    end
  end

end
