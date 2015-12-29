
RSpec.describe Secure::UserProfile, 'Contains the users presence.' do

  let(:user) {create(:user)}

  context "Initializes correctly as an UserProfile object" do
    it '#new without user_object raises error.' do
      expect{ Secure::UserProfile.new }.to raise_error(ArgumentError)
    end
    it '#new with user_object does not raise error.' do
      expect( Secure::UserProfile.new(user) ).to be_a(Secure::UserProfile)
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
    it '#method get_new_secure_token returns expected token.' do
      expect( Secure::UserProfile.get_new_secure_token ).to be_a_kind_of(String)
    end
  end

  context "Handles Instance methods from included module." do
    it '#method access_profile returns expected object.' do
      expect( Secure::UserProfile.new(user).access_profile ).to be_a_kind_of(Array)
    end
  end

end