# spec/features/authentication_process_spec.rb
#

RSpec.feature "Authentication process for all users." do


  context "Users " do
    given(:user) { FactoryGirl.create(:user) }

    scenario "Sign in with username and password credentials." do
      visit signin_url
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => user.password
      click_button 'Sign in'
      expect(current_path).to eq home_path
      expect(page).to have_title("Welcome")
    end

    scenario "Required to sign in when page is secured." do
      visit users_url
      expect(current_path).to eq signin_path
      expect(page).to have_notice_message("Please sign in to continue.")
    end

    scenario "Not required to sign in when page is unsecured." do
      visit about_url
      expect(current_path).to eq about_path
      expect(page).to have_title("About")
    end

    scenario "Returned to originally requested page after signing in." do
      user = FactoryGirl.create(:manager)
      visit users_url
      expect(current_path).to eq signin_path
      expect(page).to have_notice_message("Please sign in to continue.")
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => user.password
      click_button 'Sign in'

      # Signed on twice
      unless current_path.eql?(users_path)
        expect(current_path).to eq signin_path
        fill_in 'Username', :with => user.username
        fill_in 'Password', :with => user.password
        click_button 'Sign in'
      end

      expect(current_path).to eq users_path
      click_link 'Sign out'
    end

    scenario "Unauthorized access is redirected to Home page with unauthorized message." do
      #user = FactoryGirl.create(:manager)
      visit new_user_url
      expect(current_path).to eq signin_path
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => user.password
      click_button 'Sign in'

      # Signed on twice
      unless current_path.eql?(home_path)
        expect(current_path).to eq signin_path
        fill_in 'Username', :with => user.username
        fill_in 'Password', :with => user.password
        click_button 'Sign in'
      end

      expect(current_path).to eq home_path
      expect(page).to have_alert_message("You are not authorized to access the ")
      click_link 'Sign out'
    end

    scenario "Returned to Home page after sign out." do
      user = FactoryGirl.create(:manager)
      visit users_url
      expect(current_path).to eq signin_path
      expect(page).to have_notice_message("Please sign in to continue.")
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => user.password
      click_button 'Sign in'

      # Signed on twice
      unless current_path.eql?(users_path)
        expect(current_path).to eq signin_path
        fill_in 'Username', :with => user.username
        fill_in 'Password', :with => user.password
        click_button 'Sign in'
      end

      expect(current_path).to eq users_path
      click_link 'Sign out'
      expect(current_url).to eq root_url
      expect(page).to have_notice_message("You have been signed out.")
    end
  end

  context "Using bad credentials." do
    let(:user) { FactoryGirl.create(:user) }

    scenario "Cannot sign in with incorrect username." do
      visit signin_url
      fill_in 'Username', :with => "LastNameInitial"
      fill_in 'Password', :with => user.password
      click_button 'Sign in'
      expect(current_path).to eq sessions_path
      expect(page).to have_alert_message("Invalid username or password.")
    end

    scenario "Cannot sign in with incorrect password." do
      visit signin_url
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => "somebody"
      click_button 'Sign in'
      expect(current_path).to eq sessions_path
      expect(page).to have_alert_message("Invalid username or password.")
    end

    scenario "Cannot sign in when no credentials are offered." do
      visit signin_url
      click_button 'Sign in'
      expect(current_path).to eq sessions_path
      expect(page).to have_alert_message("Your Credentials are invalid or expired.")
    end

  end

end
