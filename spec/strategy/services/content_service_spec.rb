# spec/strategy.services/content_service_spec.rb
#

RSpec.describe Services::ContentService, "Service routines of Services::ContentService." do
  let!(:user) {user_bstester}
  let!(:userp) {page_user_bnptester}

  let(:mc) {ServiceRegistryMockController.new(user: user)}
  let(:service_registry)  { Services::ServiceRegistry.new({registry: mc}) }

  let(:service) {service_registry.content_service}


  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ Services::ContentService.new }.to raise_error(ArgumentError)
    end

    scenario "#new succeeds when :registry is valid value." do
      expect(Services::ContentService.new({registry: service_registry})).to be_a(Services::ContentService)
    end

    scenario "#new fails when :registry is invalid value." do
      expect{ Services::ContentService.new({registry: nil}) }.to raise_error(ArgumentError)
    end

    scenario "#registry.content_service returns a proper service object." do
      expect( service ).to be_a Services::ContentService
    end

    scenario "#controller #registry objects to be different." do
      expect( service.registry ).to be_a Services::ServiceRegistry
      expect( service.controller ).to be_a ServiceRegistryMockController
    end

    scenario "#current_user returns a UserProfile object." do
      expect( service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Content Profile Management methods return proper results. " do

    scenario "#handle_content_profile_management prepares a page package of all users" do
      result = service.handle_content_profile_management({})
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
      expect(result.message).to be_blank
    end

    scenario "#handle_content_profile_create" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>userp.username,
               "id"=>userp.person_authenticated_key
      }
      expect(service.handle_content_profile_create(parms).success).to be true
    end

    scenario "#handle_content_profile_update" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>user.username,
               "id"=>user.person_authenticated_key
      }
      expect(service.handle_content_profile_update(parms).success).to be true
    end

    scenario "#handle_content_profile_destroy" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>"bptester",
               "id"=>ContentProfile.first.person_authentication_key.to_s
      }
      expect(service.handle_content_profile_destroy(parms).success).to be true
    end

    scenario "#handle_content_profile_entries_create" do
      pak = ContentProfile.where(username: 'bptester').first.person_authentication_key
      parms = {
            "pak"=> pak,
            "username"=>"bptester",
            "description"=>"Samples",
            "topic_type_id"=>"1",
            "topic_type_value"=>["1"],
            "content_type_id"=>"3",
            "content_type_value"=>["9", "8", "7"],
            "button"=>"content-entry-modal"
      }
      expect(service.handle_content_profile_entries_create(parms).success).to be true
    end

    scenario "#handle_content_profile_entry_destroy" do
      id = ContentProfile.where(person_authentication_key: user.person_authenticated_key).first.content_profile_entries.first.id
      parms = {
               "id"=>id,
               'pak' => user.person_authenticated_key
      }
      expect(service.handle_content_profile_entry_destroy(parms).success).to be true
    end

  end

  context "Demo methods return proper results. " do

    scenario "#handle_demo_page" do
      result = service.handle_demo_page({})
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
    end

    scenario "#handle_api_accessible_content" do
      parms = {"id"=>"content",
                   "username"=>"developer",
                   "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
                   "content_type"=>"Commission",
                   "content_value"=>["68613"],
                   "topic_type"=>"Branch",
                   "topic_value"=>["0038"],
                   "description"=>"Determine which branch documents can be seen",
                   "topic_type_description"=>"Branch Actions for a specific branch",
                   "content_type_description"=>"Monthly Commission Reports and Files"
      }
      result = service.handle_api_accessible_content(parms)
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.package.success).to be true
    end

    scenario "#api_get_content_object" do
      parms = {"id"=>"0:0:1",
               "username"=>"developer"}
      result = service.api_get_content_object(parms)
      # catalog is not built, look for result and false
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.package.success).to be true
    end
  end


end
