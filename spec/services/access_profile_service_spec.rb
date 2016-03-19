# spec/services/access_services_spec.rb
#

RSpec.describe ApplicationController, "Service routines of AccessProfile.", :type => :controller  do
  before do
    @user = Secure::UserProfile.new( User.first )
    sign_in(@user, scope: :access_profile)
    @factory = controller.service_factory
    @service = @factory.access_services
  end

  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ ProfileDataServices.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :factory as init param." do
      expect(ProfileDataServices.new({factory: @factory})).to be_a(ProfileDataServices)
    end
    it "#new fails when :factory is invalid." do
      expect{ ProfileDataServices.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#factory.access_services returns a proper service object." do
      expect( @service ).to be_a ProfileDataServices
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

  context "Core methods delivery as designed." do

    it "#get_user_form_options returns array of options with descriptions. " do
      expect( @service.get_user_form_options ).to be_a SknUtils::PageControls
      expect( @service.get_user_form_options.groups.first.last['data-description'.to_sym] ).to be_a String
    end
    it "#group_select_options returns array of options with descriptions. " do
      expect( @service.group_select_options ).to be_a Array
      expect( @service.group_select_options.first.last['data-description'.to_sym] ).to be
    end
    it "#role_select_options returns array of options with descriptions. " do
      expect( @service.role_select_options ).to be_a Array
      expect( @service.role_select_options.first.last['data-description'.to_sym] ).to be
    end


  end



end
