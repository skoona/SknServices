# spec/services/profile_data_services_spec.rb
#

RSpec.describe ApplicationController, "Profile Data Services IO routines for ContentProfiles", :type => :controller  do
  before do
    @user = Secure::UserProfile.new( User.first )
    sign_in(@user, scope: :access_profile)
    @factory = controller.service_factory
    @service = @factory.profile_data_services
  end

  context "Initialization "  do

    scenario "#new throws an Exception without params." do
      expect{ ProfileDataServices.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when :factory is valid value." do
      expect(ProfileDataServices.new({factory: @factory})).to be_a(ProfileDataServices)
    end
    scenario "#new fails when :factory is invalid value." do
      expect{ ProfileDataServices.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when initialized via #service_factory." do
      expect(@service).to be_a ProfileDataServices
    end
    scenario "#factory and #factory.factory objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ApplicationController
    end
    scenario "#current_user and #user returns a UserProfile object." do
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
    scenario "#method_missing should try but not find this method." do
      expect{ @service.cannot_be_found() }.to raise_error(NoMethodError)
    end
  end

  context "Provided methods return proper results. " do

    # purposely exercise #method_missing in Factory::DomainsBase, via @service.params method request
    scenario "#update_content_profile_from_permitted_params" do
      @service.factory.factory.params =  ActionController::Parameters.new({"content_profile"=>{"person_authentication_key"=>"3d2e3339fa6d4555dcf55269b27eb1b9", "profile_type_id"=>"6", "authentication_provider"=>"SknService::Bcrypt", "username"=>"noprofileuser", "email"=>"noprofileuser@example.com"}})
      parms = @service.params.require(:content_profile).permit(:person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email)
      result = @service.update_content_profile_from_permitted_params(parms.merge(id: 2))
      expect(result).to be_a ContentProfile
    end
    scenario "#create_content_profile_from_permitted_params" do
      @service.factory.factory.params =  ActionController::Parameters.new({"content_profile"=>{"person_authentication_key"=>"3d2e3339fa6d4555dcf55269b27eb1b9", "profile_type_id"=>"6", "authentication_provider"=>"SknService::Bcrypt", "username"=>"noprofileuser", "email"=>"noprofileuser@example.com"}})
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



end
