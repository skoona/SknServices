# spec/services/content_profile_service_spec.rb
#

RSpec.describe ApplicationController, "Service routines of ContentProfileService.", :type => :controller  do
  before do
    @user = Secure::UserProfile.new( User.first )
    sign_in(@user, scope: :access_profile)
    @factory = controller.service_factory
    @service = @factory.content_profile_service
  end

  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ ContentProfileService.new }.to raise_error(ArgumentError)
    end

    it "#new succeeds with only :controller as init param." do
      expect(ContentProfileService.new({controller: controller})).to be_a(ContentProfileService)
    end
    it "#new succeeds with only :factory as init param." do
      expect(ContentProfileService.new({factory: controller})).to be_a(ContentProfileService)
    end
    it "#new succeeds with all :factory, :controller, and :user as init params." do
      expect(ContentProfileService.new({factory: controller, controller: controller, user: @user})).to be_a(ContentProfileService)
    end

    it "#new fails when :controller is invalid." do
      expect{ ContentProfileService.new({controller: nil}) }.to raise_error(ArgumentError)
    end
    it "#new fails when :factory is invalid." do
      expect{ ContentProfileService.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#new recovers when :factory is invalid, :controller is valid." do
      expect( ContentProfileService.new({factory: nil, controller: controller}) ).to be_a(ContentProfileService)
    end

    it "#factory.content_profile_service returns a proper service object." do
      expect( @service ).to be_a ContentProfileService
    end
    it "#service #factory and #controller objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ApplicationController
      expect( @service.factory.controller ).to be_a ApplicationController
      expect( @service.controller ).to be_a ApplicationController
    end
    it "#current_user and #user returns a UserProfile object." do
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.factory.user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
      expect( @service.user ).to be_a Secure::UserProfile
    end
  end




end
