# spec/services/access_services_spec.rb
#

RSpec.describe AccessProfileService, "Service routines of AccessProfile and AccessProfileDomain."  do
  let!(:user) {user_bstester}

  let(:mc) {ServiceFactoryMockController.new(user: user)}
  let(:service_factory)  { ServiceFactory.new({factory: mc, user: user}) }

  let(:service) {service_factory.access_profile_service}

  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ AccessProfileService.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds with only :factory as init param." do
      expect(AccessProfileService.new({factory: service_factory})).to be_a(AccessProfileService)
    end
    scenario "#new fails when :factory is invalid." do
      expect{ AccessProfileService.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#factory.profile_data_services returns a proper service object." do
      expect( service ).to be_a AccessProfileService
    end
    scenario "#service #factory and #controller objects to be different." do
      expect( service.factory ).to be_a ServiceFactory
      expect( service.service.factory ).to be_a ServiceFactoryMockController
      expect( service.factory.controller ).to be_a ServiceFactoryMockController
    end
    scenario "#current_user returns a UserProfile object." do
      expect( service.factory.current_user ).to be_a Secure::UserProfile
      expect( service.current_user ).to be_a Secure::UserProfile
    end
  end

  
end
