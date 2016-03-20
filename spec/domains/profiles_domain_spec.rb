# spec/domains/profile_domain_spec.rb
#
# By replacing ApplicationController and type: :controlle, with ProfilesDomain
# we are able to run test faster and without overhead of a test contoller.
# this will work for Domain(s) that don't require a full controller
#

RSpec.describe ProfilesDomain, "Service routines of ProfilesDomain." do

  let(:user) { Secure::UserProfile.new( User.first ) }

  # Mocking ApplicationController, so self will behave like an ApplicationController
  # All because we changes to ProfilesDomain from ApplicationController
  def current_user
    user
  end
  def controller
    self
  end


  before do
    @factory = ServiceFactory.new(factory: self)
    @service = ProfilesDomain.new({factory: @factory})
  end

  context "Initialization "  do
    scenario "#new throws an Exception without params." do
      expect{ ProfilesDomain.new }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when :factory is valid value." do
      expect(ProfilesDomain.new({factory: @factory})).to be_a(ProfilesDomain)
    end
    scenario "#new fails when :factory is invalid value." do
      expect{ ProfilesDomain.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    scenario "#new succeeds when initialized via #service_factory and a #domain_service." do
      expect(@factory.profile_data_services).to be_kind_of ProfilesDomain
    end
    scenario "#service returns an #is_a ProfilesDomain object." do
      expect( @service ).to be_a ProfilesDomain
    end
    scenario "#current_user returns a UserProfile object." do
      expect( @service.current_user ).to be_a Secure::UserProfile
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
    end
    scenario "#service.factory.factory returns the controller object." do
      expect( @service.controller ).to be_equal self
      expect( @service.factory.factory ).to be_equal self
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
      let!(:aptesterA) {@service.get_page_user("aptester", "access")}
      let!(:estesterA) {@service.get_page_user("estester", "access")}
      let!(:aptesterC) {@service.get_page_user("aptester", "content")}
      let!(:estesterC) {@service.get_page_user("vstester", "content")}

    context "For user aptester, that has content and access profiles available. " do
      scenario "#api_accessible_content(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'aptester', access: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'aptester', access: 'access'}).package.success).to be true
      end
      scenario "#api_accessible_content(content) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'aptester', access: 'content'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'aptester', access: 'content'}).package.success).to be true
      end
    end
    context "For user estester, that has access but no content profile available. " do
      scenario "#handle_accessible_content_api(access) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'estester', access: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.handle_accessible_content_api({username: 'estester', access: 'access'}).package.success).to be true
      end
      scenario "#handle_accessible_content_api(content) return a PageControls object. " do
        expect(@service.handle_accessible_content_api({username: 'estester', access: 'content'})).to be_a(SknUtils::PageControls)
      end
    end

    context "For user aptester, that has content and access profiles available. " do
      scenario "#access_profile_package(access) returns True with a Hash object. " do
        expect(@service.access_profile_package(aptesterA)).to be_a(Hash)
        expect(@service.access_profile_package(aptesterA)[:success]).to be true
      end
      scenario "#content_profile_package(content) returns True with a Hash object." do
        expect(@service.content_profile_package(aptesterC)).to be_a(Hash)
        expect(@service.content_profile_package(aptesterC)[:success]).to be true
      end
    end
    context "For user estester, that has access but no content profile available. " do
      scenario "#access_profile_package(access) returns True with a Hash object." do
        expect(@service.access_profile_package(estesterA)).to be_a(Hash)
        expect(@service.access_profile_package(estesterA)[:success]).to be true
      end
      scenario "#content_profile_package(content) returns False with a Hash object. " do
        expect(@service.content_profile_package(estesterC)).to be_a(Hash)
        expect(@service.content_profile_package(estesterC)[:success]).to be false
      end
    end
  end


end
