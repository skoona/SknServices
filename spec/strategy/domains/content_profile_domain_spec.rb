# spec/strategy.domains/content_profile_domain_spec.rb
#
# By replacing ApplicationController and type: :controller, with Domains::ContentProfileDomain
# we are able to run test faster and without overhead of a test contoller.
# this will work for Domain(s) that don't require a full controller
#

RSpec.describe Domains::ContentProfileDomain, "Service routines of Domains::ContentProfileDomain." do

  let!(:user) { page_user_eptester }
  let!(:userp) { page_user_bnptester }
  let!(:mc) {ServiceRegistryMockController.new(user: user)}
  let!(:service_registry)  { Services::ServiceRegistry.new({registry: mc}) }

  before do
    @service = service_registry.content_service
  end

  context "Initialization "  do
    scenario "#new throws an Exception without params." do
      expect{ Domains::ContentProfileDomain.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when :registry is valid value." do
      expect(Domains::ContentProfileDomain.new({registry: service_registry})).to be_a(Domains::ContentProfileDomain)
    end
    scenario "#new fails when :registry is invalid value." do
      expect{ Domains::ContentProfileDomain.new({registry: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when initialized via #service_registry and a #domain_service." do
      expect(service_registry.content_service).to be_kind_of Domains::ContentProfileDomain
    end
    scenario "#service returns an #is_a Domains::ContentProfileDomain object." do
      expect( @service ).to be_kind_of Domains::ContentProfileDomain
    end
    scenario "#current_user returns a UserProfile object." do
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
    scenario "#service.controller returns the controller object." do
      expect( @service.controller ).to be_a ServiceRegistryMockController
    end
  end

  context "Provided methods return proper results. " do
    scenario "#get_page_user() returns a array of hashes, a hash for each user." do
      result = @service.get_page_users("access")
      expect(result).to be_a(Array)
      expect(result.first).to be_a(Hash)
    end
    scenario "#get_page_user(username) returns a UserProfile object as expected." do
      result = @service.get_page_user(user.username, "access")
      expect(result).to be_a(Secure::UserProfile)
    end
    scenario "#management_profiles" do
      result = @service.management_page_users_package('content')
      expect(result[:package]).to be_a(Array)
      expect(result[:package].first).to be_a(Hash)
    end
    scenario "#get_content_object_api" do
      result = @service.get_content_object_api({})
      expect(result).to be_a(Hash)
      expect(result[:success]).to be false
    end
  end

  context "Controller accessible methods handle requests properly. " do
      let!(:bptesterA) {@service.get_page_user("bptester", "access")}
      let!(:vstesterA) {@service.get_page_user("vstester", "access")}
      let!(:bptesterC) {@service.get_page_user("bptester", "content")}
      let!(:vstesterC) {@service.get_page_user("vstester", "content")}
      let!(:bpc_parms) {{"id"=>"content", "username"=>"bptester", "user_options"=>["BranchSecondary", "0037", "USA"],
                         "content_type"=>"Activity", "content_value"=>["*.pdf"], "topic_type"=>"Partner", "topic_value"=>["0099"],
                         "description"=>"Relationship Activity Reports", "topic_type_description"=>"This Corporate Account",
                         "content_type_description"=>"This Corporate Account"}}
      let!(:bpa_parms) {{"id"=>"access", "username"=>"bptester", "user_options"=>["BranchSecondary", "0037", "USA"],
                         "uri"=>"Commission/Branch/CSV", "resource_options"=>{"uri"=>"Commission/Branch/CSV",
                                                                              "role"=>"Test.Branch.Commission.Statement.CSV.Access", "role_opts"=>["0037"]},
                         "content_type"=>"Commission", "content_value"=>["*.log", "*.csv"], "topic_type"=>"Branch",
                         "topic_value"=>["0037"], "description"=>"Branch Commission CSV Datafiles", "topic_type_description"=>"Branch Commission CSV Datafiles",
                         "content_type_description"=>"Branch Commission CSV Datafiles"}
      }
      let!(:vsa_parms) {{"id"=>"access", "username"=>"vstester", "user_options"=>["VendorSecondary", "0099"],
                         "uri"=>"Activity/Partner/0099", "resource_options"=>{"uri"=>"Activity/Partner/0099", "role"=>"Services.UserGroups.Use.FileDownload.Pdf",
                                                                              "role_opts"=>["0099"]},
                         "content_type"=>"Activity", "content_value"=>["*.pdf"], "topic_type"=>"Partner", "topic_value"=>["0099"],
                         "description"=>"Partner Relationship Reports", "topic_type_description"=>"Partner Relationship Reports",
                         "content_type_description"=>"Partner Relationship Reports"}
      }

    context "For user bptester, that has content and access profiles available. " do
      scenario "#handle_accessible_content_api(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api(bpa_parms)).to be_a(Array)
        expect(@service.handle_accessible_content_api(bpa_parms)[0][0]).to be_a(Hash)
        expect(@service.handle_accessible_content_api(bpa_parms)[1]).to be_a(String)
        expect(@service.handle_accessible_content_api(bpa_parms)[0]).not_to be_empty
      end
      scenario "#handle_accessible_content_api(content) return a PageControls object. " do
        expect(@service.handle_accessible_content_api(bpc_parms)[0]).to be_a(Array)
        expect(@service.handle_accessible_content_api(bpc_parms)[0]).not_to be_empty
      end
    end
    context "For user estester, that has access but no content profile available. " do
      scenario "#handle_accessible_content_api(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api(vsa_parms)[0]).to be_a(Array)
        expect(@service.handle_accessible_content_api(vsa_parms)[0]).not_to be_empty
      end
    end

    context "For user bptester, that has content and access profiles available. " do
      scenario "#access_profile_package(access) returns True with a Hash object. " do
        expect(@service.access_profile_package(bptesterA)).to be_a(Hash)
        expect(@service.access_profile_package(bptesterA)[:success]).to be true
      end
      scenario "#content_profile_package(content) returns True with a Hash object." do
        expect(@service.content_profile_package(bptesterC)).to be_a(Hash)
        expect(@service.content_profile_package(bptesterC)[:success]).to be true
      end
    end
    context "For user vstester, that has access but no content profile available. " do
      scenario "#access_profile_package(access) returns True with a Hash object." do
        expect(@service.access_profile_package(vstesterA)).to be_a(Hash)
        expect(@service.access_profile_package(vstesterA)[:success]).to be true
      end
      scenario "#content_profile_package(content) returns False with a Hash object. " do
        expect(@service.content_profile_package(vstesterC)).to be_a(Hash)
        expect(@service.content_profile_package(vstesterC)[:success]).to be false
      end
    end
  end

  context "Profile Data Services methods return proper results. " do

    # purposely exercise #method_missing in Registry::DomainsBase, via @service.params method request
    scenario "#update_content_profile_with_profile_type_id" do
      parms = {"profile_type_id"=>"6",
               "button"=>"content-profile-modal",
               "username"=>user.username,
               "id"=>user.person_authenticated_key
      }
      expect(@service.update_content_profile_with_profile_type_id(parms)).to be true
    end
    scenario "#create_content_profile_with_profile_type_id" do
      parms = {"profile_type_id"=>"5",
       "button"=>"content-profile-modal",
               "username"=>userp.username,
               "id"=>userp.person_authenticated_key
      }
      expect(@service.create_content_profile_with_profile_type_id(parms)).to be true
    end
    scenario "#destroy_content_profile_by_pak" do
      parms = {"profile_type_id"=>"5",
               "button"=>"content-profile-modal",
               "username"=>user.username,
               "id"=>user.person_authenticated_key
      }
      expect(@service.destroy_content_profile_by_pak(parms)).to be true
    end

    scenario "#create_content_profile_entries" do
      cp = ContentProfile.where(username: 'bptester').first
      parms = {
            "pak"=> cp.person_authentication_key,
            "username"=>"bptester",
            "description"=>"Samples",
            "topic_type_id"=>"1",
            "topic_type_value"=>["1"],
            "content_type_id"=>"3",
            "content_type_value"=>["9", "8", "7"],
            "button"=>"content-entry-modal"
      }
      expect(@service.create_content_profile_entries(parms)).to be true
    end
    scenario "#destroy_content_profile_entry" do
      id = ContentProfile.where(person_authentication_key: user.person_authenticated_key).first.content_profile_entries.first.id
      parms = {
          "id"=>id,
          'pak' => user.person_authenticated_key
      }
      expect(@service.destroy_content_profile_entry(parms)).to be true
    end

  end


end
