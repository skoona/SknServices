# spec/services/content_service_spec.rb
#

RSpec.describe ContentService, "Service routines of ContentService." do
  let!(:user) {user_bstester}

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

  context "Provided methods return proper results. " do

    scenario "#handle_content_profile_destroy" do
      result = service.handle_content_profile_destroy({id: 2})
      expect(result).to be_a(SknUtils::ResultBean)
      expect(result.success).to be true
    end

    scenario "#handle_content_profile_update" do
    end

    scenario "#handle_content_profile_creations" do
    end

    scenario "#handle_content_profile_index" do
      result = service.handle_content_profile_index({})
      expect(result).to be_a(SknUtils::ResultBean)
      expect(result.success).to be true
    end

    scenario "#handle_content_profile_show_or_edit" do
      result = service.handle_content_profile_show_or_edit({id: 2})
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.success).to be true
    end

    scenario "#handle_content_profile_new" do
      result = service.handle_content_profile_new()
      expect(result).to be_a(SknUtils::ResultBean)
      expect(result.success).to be true
    end

  end

  context "Provided methods return proper results. " do

    scenario "#handle_demo_page" do
      result = service.handle_demo_page({})
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.success).to be true
    end

    scenario "#handle_api_accessible_content" do
    end

    scenario "#handle_content_profile_management prepares a page package of all users" do
      result = service.handle_content_profile_management({})
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.success).to be false
      expect(result.message).to be_blank
    end

    scenario "#api_get_content_object" do
    end
  end


end
