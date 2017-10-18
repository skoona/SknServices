# spec/strategy.services/content_service_spec.rb
#

RSpec.describe Services::ContentService, "Service routines of Services::ContentService." do
  let!(:user) {user_developer}
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
      expect(service.handle_content_profile_create({}).success).to be false
    end

    scenario "#handle_content_profile_update" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>user.username,
               "id"=>user.person_authenticated_key
      }
      expect(service.handle_content_profile_update(parms).success).to be true
      expect(service.handle_content_profile_update({}).success).to be false
    end

    scenario "#handle_content_profile_destroy" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>"bptester",
               "id"=>ContentProfile.first.person_authentication_key.to_s
      }
      expect(service.handle_content_profile_destroy(parms).success).to be true
      expect(service.handle_content_profile_destroy({}).success).to be false
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
      expect(service.handle_content_profile_entries_create({}).success).to be false
    end

    scenario "#handle_content_profile_entry_destroy" do
      id = ContentProfile.where(person_authentication_key: user.person_authenticated_key).first.content_profile_entries.first.id
      parms = {
               "id"=>id,
               'pak' => user.person_authenticated_key
      }
      expect(service.handle_content_profile_entry_destroy(parms).success).to be true
      expect(service.handle_content_profile_entry_destroy({}).success).to be false
    end

  end

  context "Developers In Action Pages. " do

    scenario "#handle_in_action_admin" do
      result = service.handle_in_action_admin({})
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
      expect(service.handle_api_accessible_content({}).package.success).to be false
    end

    scenario "#api_get_content_object" do
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
      catalog = service.handle_api_accessible_content(parms)
      expect(catalog.package.success).to be true

      parms = {"id"=>"0:0:0",
               "username"=>"developer",
               "content_type"=>"Commission"
      }

      result = service.api_get_content_object(parms)
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
      expect(service.api_get_content_object({}).success).to be false
    end

  end

  context "Users In Action Pages. " do

    scenario "#handle_in_action" do
      result = service.handle_in_action()
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
    end

    scenario "#api_get_demo_content_object " do
      parms = {"id"=>"0:0:0",
               "username"=>"developer",
               'content_type'=>"Commission"
      }
      catalog = service.handle_in_action()
      expect(catalog.success).to be true

      result = service.api_get_demo_content_object(parms)
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
      expect(service.api_get_demo_content_object({}).success).to be false
    end
  end

  context "Administrators In Action Pages. " do

    scenario "#handle_members" do
      result = service.handle_members()
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
    end

    scenario "#handle_member" do
      parms = {
          "username"=>"bstester",
          "display_name"=>"Branch Secondary User",
          "id"=>user.person_authenticated_key
      }
      result = service.handle_member(parms)
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
      expect(service.handle_member({}).success).to be false
    end

    scenario "#handle_member_updates " do
      parms = {
            "member"=>{
                "0037"=>{"Commission"=>"on", "Experience"=>"on", "Notification"=>["FutCancel", "Cancel"], "LicensedStates"=>["20", "21"]},
                "0034"=>{"Commission"=>"on", "Experience"=>"on", "Notification"=>["FutCancel", "Cancel"], "LicensedStates"=>["20", "21"]},
                "0040"=>{"Commission"=>"on", "Experience"=>"on", "Notification"=>["FutCancel", "Cancel"], "LicensedStates"=>["20", "21"]},
                "activity"=>{"partners"=>["0099"]},
                "filedownload"=>{"usergroups"=>["EmployeePrimary", "EmployeeSecondary", "BranchPrimary"]}
            },
            "commit"=>"bstester",
            "id"=> user.person_authenticated_key
          }

      result = service.handle_member_updates(parms)
      expect(result).to be_a(SknUtils::NestedResult)
      expect(result.success).to be true
      expect(service.handle_member_updates(false).success).to be false
    end
  end

end
