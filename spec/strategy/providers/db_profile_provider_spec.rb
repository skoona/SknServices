# spec/strategy.services/profile_builder_spec.rb
#

describe Providers::DBProfileProvider, "Service routines of Provider::DBProfileProvider."  do
  let(:user) {page_user_developer}

  let(:mc) {ServiceFactoryMockController.new(user: user)}
  let(:service_factory)  { ServiceFactory.new({factory: mc}) }

  before do
    Secure::ObjectStorageContainer.instance.test_reset!
    login_as(user, scope: :access_profile)
    @service = service_factory.db_profile_provider
    @auth = AccessRegistryTestUser.new(["Test.Action.Read"])
    Secure::ObjectStorageContainer.instance.test_reset!
  end

  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ Providers::DBProfileProvider.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :factory as init param." do
      expect(Providers::DBProfileProvider.new({factory: service_factory})).to be_a(Providers::DBProfileProvider)
    end
    it "#new fails when :factory is invalid." do
      expect{ Providers::DBProfileProvider.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#factory.profile_data_services returns a proper service object." do
      expect( @service ).to be_a Providers::DBProfileProvider
    end
    it "#service #factory and #controller objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ServiceFactoryMockController
    end
    it "#current_user returns a UserProfile object." do
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
    it "#provider_type returns a Content as type." do
      expect( @service.provider_type ).to eq("Providers::DBProfileProvider")
    end
  end

  context "Core routines deliver as designed" do

    it "#content_profile_for_user returns hash" do
      expect( @service.content_profile_for_user(user) ).to be_a Hash
    end
    it "#content_profile_for_user returns bean" do
      expect( @service.content_profile_for_user(user,true) ).to be_a Utility::ContentProfileBean
    end
    it "#get_existing_profile returns nil" do
      expect( @service.send(:get_existing_profile, @auth) ).to be_nil
    end
    it "#get_existing_profile returns found object" do
      expect( @service.content_profile_for_user(user,true) ).to be_a Utility::ContentProfileBean
      expect( @service.send(:get_existing_profile, user) ).to be_a Hash
    end
  end

  context "Core routines handle not found errors properly. " do

     it "#content_profile_for_user should handle user with no permissions" do
       expect( @service.content_profile_for_user(@auth,true).success ).to be false
     end
    it "#content_profile_for_user should handle :not_found user object" do
      expect( @service.content_profile_for_user(@auth,true).success ).to be false
    end
     it "#content_profile_for_user should handle nil user object" do
       expect( @service.content_profile_for_user(nil,true).success ).to be false
     end
     it "#get_existing_profile should raise error on nil user." do
       expect{ @service.send(:get_existing_profile, nil) }.to raise_error(Utility::Errors::NotFound)
     end
  end

end
