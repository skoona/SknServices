# spec/domains/content_profile_domain_spec.rb
#
# TODO: alternate way =  # login_as(@user, scope: :access_profile)

RSpec.describe ApplicationController, "Service routines of ProfilesDomain.", :type => :controller do

  before do
    @user = Secure::UserProfile.new( User.first )
    warden_use_user(@user, scope: :access_profile)
    @service = ProfilesDomain.new({factory: controller, controller: controller, user: @user})
  end

  context "Initialization "  do
    it "#new throws an Exception without params." do
      expect{ ProfilesDomain.new }.to raise_error(ArgumentError)
    end

    it "#new succeeds with only :controller as init param." do
      expect(ProfilesDomain.new({controller: controller})).to be_a(ProfilesDomain)
    end
    it "#new succeeds with only :factory as init param." do
      expect(ProfilesDomain.new({factory: controller})).to be_a(ProfilesDomain)
    end
    it "#new succeeds with all :factory, :controller, and :user as init params." do
      expect(@service).to be_a(ProfilesDomain)
    end

    it "#new fails when :controller is invalid." do
      expect{ ProfilesDomain.new({controller: nil}) }.to raise_error(ArgumentError)
    end
    it "#new fails when :factory is invalid." do
      expect{ ProfilesDomain.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#new recovers when :factory is invalid, :controller is valid." do
      expect( ProfilesDomain.new({factory: nil, controller: controller}) ).to be_a(ProfilesDomain)
    end
    it "#service returns a proper domain object." do
      expect( @service ).to be_a ProfilesDomain
    end
    it "#current_user and #user returns a UserProfile object." do
      expect( @service.user ).to be_a Secure::UserProfile
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.factory.user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Common methods return proper results. " do
    it "#get_page_user() returns a array of hashes, a hash for each user." do
      result = @service.get_page_users("access")
      expect(result).to be_a(Array)
      expect(result.first).to be_a(Hash)
    end
    it "#get_user_form_options() returns a PageControls object with two methods containing array of arrays." do
      result = @service.get_user_form_options()
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.to_hash().keys.size).to be > 1
    end
    it "#get_page_user(username) returns a UserProfile object as expected." do
      result = @service.get_page_user(@user.username, "access")
      expect(result).to be_a(Secure::UserProfile)
      expect(@service.page_user.username).to eq( @user.username )
    end
    it "#get_page_access_profile() returns a array of hashes as expected." do
      expect( @service.get_page_user(@user.username, "access") ).to be_a(Secure::UserProfile)
      result = @service.get_page_access_profile()
      expect(result).to be_a(Array)
      expect(result.first).to be_a(Hash)
    end
    it "#get_page_content_profile() returns a hash as expected, AFTER BEING ENABLE." do
      expect(@user.enable_authentication_controls()).to be true
        result = @service.get_page_content_profile()
      expect(@user.disable_authentication_controls()).to be true

      expect(result).to be_a(Hash)
      expect(result[:entries]).to be_a(Array)
    end
  end



end
