# spec/features/profile/profile_demo_process_spec.rb
#

RSpec.feature "Profile Demo Process." do

  context "AccessProfile Demo. " do

    scenario "Clicking profile loads Accessible table" do
      visit signin_url
      expect(current_path).to eq signin_path
      # save_screenshot('AccessProfileDemoPageRSpec.png', :full => true)
      fill_in 'Username', :with => "eptester"
      fill_in 'Password', :with => "nobugs"
      click_button 'Sign in'
      expect(current_path).to eq home_pages_path

      visit access_profile_demo_profiles_url
      expect(current_path).to eq access_profile_demo_profiles_path

      # expect(page).to have_css('#access-table tbody tr')
      # find('#access-table tbody tr').click
      # expect(page).to have_css('#accessible-table tbody tr.success')

      click_link 'Sign out'
    end

    scenario "Returned to originally requested page after signing in." do
    end

  end

  context "ContentProfile Demo. " do

    scenario "Clicking profile loads Accessible table" do
      visit signin_url
      expect(current_path).to eq signin_path
      fill_in 'Username', :with => "skoona"
      fill_in 'Password', :with => "developer99"
      click_button 'Sign in'
      expect(current_path).to eq home_pages_path

      visit content_profile_demo_profiles_url
      expect(current_path).to eq content_profile_demo_profiles_path

      click_link 'Sign out'
    end
  end

end
