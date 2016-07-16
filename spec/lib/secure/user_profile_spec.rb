
RSpec.describe Secure::UserProfile, 'Contains the users presence.' do

  let(:user) {create(:user)}

  context "Initializes correctly as an UserProfile object" do
    it '#new without user_object raises error.' do
      expect{ Secure::UserProfile.new }.to raise_error(ArgumentError)
    end
    it '#new with user_object does not raise error.' do
      expect( Secure::UserProfile.new(user) ).to be_a(Secure::UserProfile)
    end
    it '#method find_and_authenticate_user(name,pass) works as expected.' do
      expect( Secure::UserProfile.find_and_authenticate_user(user.username, user.password)).to be_a_kind_of(Secure::UserProfile)
    end
  end

  context "Delegates missing instance methods to the user_object it contains." do
    it '#display_name on user object returns expected string.' do
      expect( Secure::UserProfile.new(user).display_name ).to be_a(String)
    end
    it '#method generate_unique_token on user object returns true.' do
      token = user.password_reset_token
      expect( Secure::UserProfile.new(user).generate_unique_token(:password_reset_token) ).to be true
      expect(token.eql?(user.password_reset_token)).to be false
    end
    it '#method authenticate(param) returns expected object.' do
      expect( Secure::UserProfile.new(user).authenticate(user.password) ).to be_a_kind_of(Secure::UserProfile)
    end
  end

  context "Handles Class methods from included module." do
    it '#method generate_new_storage_key returns expected token.' do
      expect( Secure::UserProfile.generate_new_storage_key ).to be_a_kind_of(String)
    end
  end

  context "Handles Instance methods from included module." do
    it '#method access_profile returns expected object.' do
      expect( Secure::UserProfile.new(user).combined_access_roles ).to be_a_kind_of(Array)
    end
  end

  context "Handles internal ActiveRecord Class methods." do
    it '#method fetch_remembered_user() works as expected.' do
      expect( Secure::UserProfile.fetch_remembered_user(user.remember_token) ).to be_a_kind_of(Secure::UserProfile)
    end
    it '#method enable_authentication_controls() works as expected.' do
      expect( Secure::UserProfile.new(user).enable_authentication_controls() ).to be true
    end
    it '#method disable_authentication_controls() works as expected.' do
      u = Secure::UserProfile.new(user)
      expect( u.enable_authentication_controls() ).to be true
      expect( u.disable_authentication_controls() ).to be true
    end
    it '#method fetch_cached_user() works as expected.' do
      u = Secure::UserProfile.new(user)
      expect( u.enable_authentication_controls() ).to be true
      expect( Secure::UserProfile.count_storage_objects).to be > 0
      expect( Secure::UserProfile.fetch_cached_user(u.person_authenticated_key)).to be_a_kind_of(Secure::UserProfile)
      expect( u.disable_authentication_controls() ).to be true
    end
  end

end