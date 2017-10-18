# spec/strategy.services/access_services_spec.rb
#

RSpec.describe Services::AccessService, "Service routines of AccessProfile and AccessProfileDomain."  do
  let!(:user) {user_bstester}

  let(:mc) {ServiceRegistryMockController.new(user: user)}
  let(:service_registry)  { Services::ServiceRegistry.new({registry: mc}) }

  let(:service) {service_registry.access_service}

  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds with only :registry as init param." do
      expect(described_class.new({registry: service_registry})).to be_a(described_class)
    end
    scenario "#new fails when :registry is invalid." do
      expect{ described_class.new({registry: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#registry.profile_data_services returns a proper service object." do
      expect( service ).to be_a described_class
    end
    scenario "#service #registry and #controller objects to be different." do
      expect( service.registry ).to be_a Services::ServiceRegistry
      expect( service.controller ).to be_a ServiceRegistryMockController
    end
    scenario "#current_user returns a UserProfile object." do
      expect( service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Services methods delivery as designed." do

    scenario "#get_user_form_options returns array of options with descriptions. " do
      expect( service.get_user_form_options ).to be_a SknUtils::NestedResult
      expect( service.get_user_form_options.groups.first.last['data-description'.to_sym] ).to be_a String
    end
    scenario "#get_user_form_options() returns a PageControls object with two methods containing array of arrays." do
      result = service.get_user_form_options()
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.to_hash().keys.size).to be > 1
    end

  end

  context "User methods delivery as designed." do

    scenario "#handle_users_index returns array of User object. " do
      package = service.handle_users_index({})
      expect( package ).to be_a SknUtils::NestedResult
      expect( package.users.first ).to be_a User
    end

  end

  context "System Information methods work as designed" do

    scenario "#handle_system_information_api performs action requested" do
      expect(service.handle_system_information_api({id: 'xml'}).success).to be true
      expect(service.handle_system_information_api({id: 'purge'}).success).to be true
      expect(service.handle_system_information_api({}).success).to be false
    end

    scenario "#handle_system_information returns information bundle." do
      expect(service.handle_system_information({}).success).to be true
    end
  end


end
