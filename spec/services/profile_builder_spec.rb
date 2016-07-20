# spec/services/profile_builder_spec.rb
#

describe ApplicationController, "Service routines of Builder::ProfileBuilder.", :type => :controller  do
  before do
    @user = page_user_eptester
    sign_in(@user, scope: :access_profile)
    @factory = controller.service_factory
    @service = @factory.profile_builder
  end

  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ Builder::ProfileBuilder.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :factory as init param." do
      expect(Builder::ProfileBuilder.new({factory: @factory})).to be_a(Builder::ProfileBuilder)
    end
    it "#new fails when :factory is invalid." do
      expect{ Builder::ProfileBuilder.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#factory.profile_data_services returns a proper service object." do
      expect( @service ).to be_a Builder::ProfileBuilder
    end
    it "#service #factory and #controller objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ApplicationController
      expect( @service.factory.controller ).to be_a ApplicationController
    end
    it "#current_user returns a UserProfile object." do
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Core routines deliver as designed" do

    before :each do
      @auth = AccessRegistryTestUser.new(["Test.Action.Read"])
      @service.factory.class.purge_older_than_two_days(1)
    end

    it "#combined_profiles returns hash" do
      expect( @service.combined_profiles(@user) ).to be_a Array
      expect( @service.combined_profiles(@user)[0] ).to be_a Hash
      expect( @service.combined_profiles(@user)[1] ).to be_a Hash
    end
    it "#combined_profiles returns bean" do
      expect( @service.combined_profiles(@user,true) ).to be_a Array
      expect( @service.combined_profiles(@user,true)[0] ).to be_a Utility::ContentProfileBean
      expect( @service.combined_profiles(@user,true)[1] ).to be_a Utility::ContentProfileBean
    end
    it "#content_profile returns hash" do
      expect( @service.content_profile(@user) ).to be_a Hash
    end
    it "#content_profile returns bean" do
      expect( @service.content_profile(@user,true) ).to be_a Utility::ContentProfileBean
    end
    it "#access_profile returns hash" do
      expect( @service.access_profile(@user) ).to be_a Hash
    end
    it "#access_profile returns bean" do
      expect( @service.access_profile(@user,true) ).to be_a Utility::ContentProfileBean
    end
    it "#get_existing_content_profile returns nil" do
      expect( @service.get_existing_content_profile(@auth) ).to be_nil
    end
    xit "#get_existing_content_profile returns found object" do
      expect( @service.content_profile(@user,true) ).to be_a Utility::ContentProfileBean
      expect( @service.get_existing_content_profile(@user) ).to be_a Hash
    end
    it "#get_existing_access_profile returns nil" do
      expect( @service.get_existing_access_profile(@auth) ).to be_nil
    end
    it "#get_existing_access_profile returns found object" do
      expect( @service.access_profile(@user,true) ).to be_a Utility::ContentProfileBean
      expect( @service.get_existing_access_profile(@user) ).to be_a Hash
    end
  end

  context "Core routines handle not found errors properly. " do
     before :each do
       @auth = AccessRegistryTestUser.new(["Test.Action.Read"])
       @service.factory.class.purge_older_than_two_days(1)
     end

     it "#content_profile should handle user with no permissions" do
       expect( @service.content_profile(@auth,true).success ).to be false
     end
    it "#content_profile should handle :not_found user object" do
      expect( @service.content_profile(@auth,true).success ).to be false
    end
     it "#content_profile should handle nil user object" do
       expect( @service.content_profile(nil,true).success ).to be false
     end
     it "#access_profile should handle :not_found user object" do
       expect( @service.access_profile(@auth,true).success ).to be false
     end
     it "#access_profile should handle nil user object" do
       expect( @service.access_profile(nil,true).success ).to be false
     end
     it "#access_profile should handle user with no permissions" do
       expect( @service.access_profile(@auth,true).success ).to be false
     end
     it "#get_existing_access_profile should handle nil user." do
       expect{ @service.get_existing_access_profile(nil) }.to raise_error(Utility::Errors::NotFound)
     end
     it "#get_existing_content_profile should handle nil user." do
       expect{ @service.get_existing_content_profile(nil) }.to raise_error(Utility::Errors::NotFound)
     end
  end

end
