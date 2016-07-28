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
    scenario "#get_page_access_profile() returns a array of hashes as expected." do
      expect( @service.get_page_user(user.username, "access") ).to be_a(Secure::UserProfile)
      result = @service.get_page_access_profile(user)
      expect(result).to be_a(Hash)
      expect(result[:entries]).to be_a(Array)
    end
    scenario "#get_page_content_profile() returns a hash as expected, AFTER BEING ENABLE." do
      result = @service.get_page_content_profile(user)
      expect(result).to be_a(Hash)
      expect(result[:entries]).to be_a(Array)
    end
    scenario "#handle_profiles_management" do
      result = @service.handle_profiles_management({})
      expect(result).to be_a(Hash)
      expect(result[:success]).to be false
    end
    scenario "#handle_content_profiles_api" do
      result = @service.handle_content_profiles_api({})
      expect(result).to be_a(Hash)
      expect(result[:success]).to be false
    end
  end

  context "Controller accessible methods handle requests properly. " do
      let!(:bptesterA) {@service.get_page_user("bptester", "access")}
      let!(:vstesterA) {@service.get_page_user("vstester", "access")}
      let!(:bptesterC) {@service.get_page_user("bptester", "content")}
      let!(:vstesterC) {@service.get_page_user("vstester", "content")}

    context "For user bptester, that has content and access profiles available. " do
      scenario "#api_accessible_content(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'bptester', id: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'bptester', id: 'access'}).package.success).to be true
      end
      scenario "#api_accessible_content(content) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'bptester', id: 'content'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'bptester', id: 'content'}).package.success).to be true
      end
    end
    context "For user estester, that has access but no content profile available. " do
      scenario "#handle_accessible_content_api(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'bnptester', id: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'bnptester', id: 'access'}).package.success).to be true
      end
      scenario "#handle_accessible_content_api(content) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'eptester', id: 'content'})).to be_a(SknUtils::PageControls)
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


end
