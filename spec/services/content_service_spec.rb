# spec/services/content_service_spec.rb
#

RSpec.describe ContentService, "Service routines of ContentService." do
  let!(:user) {user_bstester}
  let!(:userp) {page_user_bnptester}

  let(:mc) {ServiceFactoryMockController.new(user: user)}
  let(:service_factory)  { ServiceFactory.new({factory: mc, user: user}) }

  let(:service) {service_factory.content_service}


  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ ContentService.new }.to raise_error(ArgumentError)
    end

    scenario "#new succeeds when :factory is valid value." do
      expect(ContentService.new({factory: service_factory})).to be_a(ContentService)
    end
    scenario "#new fails when :factory is invalid value." do
      expect{ ContentService.new({factory: nil}) }.to raise_error(ArgumentError)
    end

    scenario "#factory.content_service returns a proper service object." do
      expect( service ).to be_a ContentService
    end
    scenario "#service #factory objects to be different." do
      expect( service.factory ).to be_a ServiceFactory
      expect( service.service.factory ).to be_a ServiceFactoryMockController
    end
    scenario "#current_user returns a UserProfile object." do
      expect( service.factory.current_user ).to be_a Secure::UserProfile
      expect( service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Management methods return proper results. " do

    scenario "#handle_content_profile_management prepares a page package of all users" do
      result = service.handle_content_profile_management({})
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.success).to be false
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
      parms = {
               "id"=>"6"
      }
      expect(service.handle_content_profile_entries_create(parms).success).to be true
    end

    scenario "#handle_content_profile_entry_destroy" do
      parms = {
               "id"=>"6"
      }
      expect(service.handle_content_profile_entry_destroy(parms).success).to be true
    end

  end

  context "Demo methods return proper results. " do

    scenario "#handle_demo_page" do
      result = service.handle_demo_page({})
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.success).to be true
    end

    scenario "#handle_api_accessible_content" do
    end

    scenario "#api_get_content_object" do
    end
  end


end
