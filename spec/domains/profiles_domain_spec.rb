# spec/domains/content_profile_domain_spec.rb
#
# TODO: alternate way =  # login_as(@user, scope: :access_profile)

RSpec.describe ApplicationController, "Service routines of ProfilesDomain.", :type => :controller do

  before do
    @user = Secure::UserProfile.new( User.first )
    sign_in(@user, scope: :access_profile)
    @service = ProfilesDomain.new({factory: controller, controller: controller, user: @user})
  end

  context "Initialization "  do
    it "#new throws an Exception without params." do
      expect{ ProfilesDomain.new }.to raise_error(ArgumentError)
    end

    it "#new succeeds with only :controller as init param." do
      expect(ProfilesDomain.new({controller: controller})).to be_a(ProfilesDomain)
    end
    it "#new succeeds with only :factory as init param." do
      expect(ProfilesDomain.new({factory: controller})).to be_a(ProfilesDomain)
    end
    it "#new succeeds with all :factory, :controller, and :user as init params." do
      expect(@service).to be_a(ProfilesDomain)
    end

    it "#new fails when :controller is invalid." do
      expect{ ProfilesDomain.new({controller: nil}) }.to raise_error(ArgumentError)
    end
    it "#new fails when :factory is invalid." do
      expect{ ProfilesDomain.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#new recovers when :factory is invalid, :controller is valid." do
      expect( ProfilesDomain.new({factory: nil, controller: controller}) ).to be_a(ProfilesDomain)
    end
    it "#service returns a proper domain object." do
      expect( @service ).to be_a ProfilesDomain
    end
    it "#current_user and #user returns a UserProfile object." do
      expect( @service.user ).to be_a Secure::UserProfile
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.factory.user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
  end

  context "Common methods return proper results. " do
    it "#get_page_user() returns a array of hashes, a hash for each user." do
      result = @service.get_page_users("access")
      expect(result).to be_a(Array)
      expect(result.first).to be_a(Hash)
    end
    it "#get_user_form_options() returns a PageControls object with two methods containing array of arrays." do
      result = @service.get_user_form_options()
      expect(result).to be_a(SknUtils::PageControls)
      expect(result.to_hash().keys.size).to be > 1
    end
    it "#get_page_user(username) returns a UserProfile object as expected." do
      result = @service.get_page_user(@user.username, "access")
      expect(result).to be_a(Secure::UserProfile)
      expect(@service.page_user.username).to eq( @user.username )
    end
    it "#get_page_access_profile() returns a array of hashes as expected." do
      expect( @service.get_page_user(@user.username, "access") ).to be_a(Secure::UserProfile)
      result = @service.get_page_access_profile(@user)
      expect(result).to be_a(Array)
      expect(result.first).to be_a(Hash)
    end
    it "#get_page_content_profile() returns a hash as expected, AFTER BEING ENABLE." do
        result = @service.get_page_content_profile(@user)

      expect(result).to be_a(Hash)
      expect(result[:entries]).to be_a(Array)
    end
  end

  context "Controller accessible methods handle requests properly. " do
      let!(:aptesterA) {@service.get_page_user("aptester", "access")}
      let!(:estesterA) {@service.get_page_user("estester", "access")}
      let!(:aptesterC) {@service.get_page_user("aptester", "content")}
      let!(:estesterC) {@service.get_page_user("estester", "content")}

      before() do
        @access = controller.service_factory.access_profile_service
        @content = controller.service_factory.content_profile_service
      end
    context "For user aptester, that has content and access profiles available. " do
      it "#api_accessible_content(access) return a PageControls object. " do
        expect(@service.api_accessible_content({username: 'aptester', access: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.api_accessible_content({username: 'aptester', access: 'access'}).package.success).to be true
      end
      it "#api_accessible_content(content) return a PageControls object. " do
        expect(@service.api_accessible_content({username: 'aptester', access: 'content'})).to be_a(SknUtils::PageControls)
        expect(@service.api_accessible_content({username: 'aptester', access: 'content'}).package.success).to be true
      end
    end
    context "For user estester, that has access but no content profile available. " do
      it "#api_accessible_content(access) return a PageControls object. " do
        expect(@service.api_accessible_content({username: 'estester', access: 'access'})).to be_a(SknUtils::PageControls)
        expect(@service.api_accessible_content({username: 'estester', access: 'access'}).package.success).to be true
      end
      it "#api_accessible_content(content) return a PageControls object. " do
        expect(@service.api_accessible_content({username: 'estester', access: 'content'})).to be_a(SknUtils::PageControls)
        expect(@content.accessible_content({username: 'estester', access: 'content'}).package.success).to be true
      end
    end

    context "For user aptester, that has content and access profiles available. " do
      it "#access_profile_package(access) return a PageControls object. " do
        expect(@access.access_profile_package(aptesterA)).to be_a(SknUtils::PageControls)
        expect(@access.access_profile_package(aptesterA).success).to be true
      end
      it "#content_profile_package(content) return a PageControls object." do
        expect(@content.content_profile_package(aptesterC)).to be_a(SknUtils::PageControls)
        expect(@content.content_profile_package(aptesterC).success).to be true
      end
    end
    context "For user estester, that has access but no content profile available. " do
      it "#access_profile_package(access) return a PageControls object." do
        expect(@access.access_profile_package(estesterA)).to be_a(SknUtils::PageControls)
        expect(@access.access_profile_package(estesterA).success).to be true
      end
      it "#content_profile_package(content) return a PageControls object. " do
        expect(@content.content_profile_package(estesterC)).to be_a(SknUtils::PageControls)
        expect(@content.content_profile_package(estesterC).success).to be false
      end
    end
  end


end
