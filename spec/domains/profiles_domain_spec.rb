# spec/domains/profile_domain_spec.rb
#
# By replacing ApplicationController and type: :controlle, with ProfilesDomain
# we are able to run test faster and without overhead of a test contoller.
# this will work for Domain(s) that don't require a full controller
#

RSpec.describe ProfilesDomain, "Service routines of ProfilesDomain." do

  let(:user) { user_eptester }
  let!(:mc) {ServiceFactoryMockController.new(user: user)}
  let!(:service_factory)  { ServiceFactory.new({factory: mc}) }

  before do
    @service = service_factory.content_profile_service
  end

  context "Initialization "  do
    scenario "#new throws an Exception without params." do
      expect{ ProfilesDomain.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when :factory is valid value." do
      expect(ProfilesDomain.new({factory: service_factory})).to be_a(ProfilesDomain)
    end
    scenario "#new fails when :factory is invalid value." do
      expect{ ProfilesDomain.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when initialized via #service_factory and a #domain_service." do
      expect(service_factory.content_profile_service).to be_kind_of ProfilesDomain
    end
    scenario "#service returns an #is_a ProfilesDomain object." do
      expect( @service ).to be_kind_of ProfilesDomain
    end
    scenario "#current_user returns a UserProfile object." do
      expect( @service.current_user ).to be_a Secure::UserProfile
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
    end
    scenario "#service.factory.factory returns the controller object." do
      expect( @service.controller ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ServiceFactoryMockController
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
      expect(result).to be_a(Hash)
      expect(result[:success]).to be false
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
                         "uri"=>"Activity/Partner/0099", "resource_options"=>{"uri"=>"Activity/Partner/0099", "role"=>"Services.Action.Use.FileDownload.Pdf",
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

    # purposely exercise #method_missing in Factory::DomainsBase, via @service.params method request
    scenario "#update_content_profile_from_permitted_params" do
      @service.service.factory.params =  ActionController::Parameters.new({"content_profile"=>{"person_authentication_key"=>"3d2e3339fa6d4555dcf55269b27eb1b9", "profile_type_id"=>"6", "authentication_provider"=>"SknService::Bcrypt", "username"=>"noprofileuser", "email"=>"noprofileuser@example.com"}})
      parms = @service.params.require(:content_profile).permit(:person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email)
      result = @service.update_content_profile_from_permitted_params(parms.merge(id: 2))
      expect(result).to be_a ContentProfile
    end
    scenario "#create_content_profile_from_permitted_params" do
      @service.service.factory.params =  ActionController::Parameters.new({"content_profile"=>{"person_authentication_key"=>"3d2e3339fa6d4555dcf55269b27eb1b9", "profile_type_id"=>"6", "authentication_provider"=>"SknService::Bcrypt", "username"=>"noprofileuser", "email"=>"noprofileuser@example.com"}})
      parms = @service.params.require(:content_profile).permit(:person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email)
      result = @service.create_content_profile_from_permitted_params(parms)
      expect(result).to be_a ContentProfile
    end
    scenario "#get_page_pagination_for_content_profile_index" do
      result = @service.get_page_pagination_for_content_profile_index({})
      expect(result.length).to be > 4
      expect(result.first).to be_a ContentProfile
    end
    scenario "#get_empty_new_content_profile" do
      result = @service.get_empty_new_content_profile
      expect(result).to be_a ContentProfile
    end
    scenario "#destroy_content_profile" do
      obj = ContentProfile.first
      result = @service.destroy_content_profile({id: obj.id})
      expect(result.id).to eq obj.id
    end
    scenario "#get_content_profiles_entries_entry_info" do
      obj = ContentProfile.first
      result = @service.get_content_profiles_entries_entry_info(obj)
      expect(result).to be_a(Array)
      expect(result.length).to be > 0
      expect(result[0][:content_value]).to be
    end
    scenario "#get_unassigned_user_attributes" do
      result = @service.get_unassigned_user_attributes()
      expect(result).to be_a(Array)
      expect(result.length).to be > 0
      expect(result[0][2][:data]).to be
    end
    scenario "#get_user_form_options() returns a PageControls object with two methods containing array of arrays." do
      result = @service.get_user_form_options()
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.to_hash().keys.size).to be > 1
    end

  end

  context "Profile Data Services methods delivery as designed." do

    scenario "#get_user_form_options returns array of options with descriptions. " do
      expect( @service.get_user_form_options ).to be_a SknUtils::PageControls
      expect( @service.get_user_form_options.groups.first.last['data-description'.to_sym] ).to be_a String
    end
    scenario "#group_select_options returns array of options with descriptions. " do
      expect( @service.group_select_options ).to be_a Array
      expect( @service.group_select_options.first.last['data-description'.to_sym] ).to be
    end
    scenario "#role_select_options returns array of options with descriptions. " do
      expect( @service.role_select_options ).to be_a Array
      expect( @service.role_select_options.first.last['data-description'.to_sym] ).to be
    end

  end


end
