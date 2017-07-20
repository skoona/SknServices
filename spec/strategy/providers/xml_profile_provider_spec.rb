# spec/strategy.services/profile_builder_spec.rb
#

describe Providers::XMLProfileProvider, "Service routines of Providers::XMLProfileProvider."  do
  let(:user) {page_user_developer}

  let(:mc) {ServiceRegistryMockController.new(user: user)}
  let(:service_registry)  { Services::ServiceRegistry.new({registry: mc}) }

  before do
    Secure::ObjectStorageContainer.instance.test_reset!
    login_as(user, scope: :access_profile)
    @service = service_registry.xml_profile_provider
    @auth = AccessRegistryTestUser.new(["Test.Action.Read"])
    Secure::ObjectStorageContainer.instance.test_reset!
  end

  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ Providers::XMLProfileProvider.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :registry as init param." do
      expect(Providers::XMLProfileProvider.new({registry: service_registry})).to be_a(Providers::XMLProfileProvider)
    end
    it "#new fails when :registry is invalid." do
      expect{ Providers::XMLProfileProvider.new({registry: nil}) }.to raise_error(ArgumentError)
    end
    it "#registry.profile_data_services returns a proper service object." do
      expect( @service ).to be_a Providers::XMLProfileProvider
    end
    it "#service #registry and #controller objects to be different." do
      expect( @service.registry ).to be_a Services::ServiceRegistry
      expect( @service.registry.registry ).to be_a ServiceRegistryMockController
    end
    it "#current_user returns a UserProfile object." do
      expect( @service.registry.current_user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
    it "#provider_type returns a Access as type." do
      expect( @service.provider_type ).to eq("Providers::XMLProfileProvider")
    end
  end

  context "Core routines deliver as designed" do

    it "#content_profile_for_user returns hash" do
      expect( @service.content_profile_for_user(user) ).to be_a Hash
    end
    it "#content_profile_for_user returns bean" do
      expect( @service.content_profile_for_user(user,true) ).to be_a Utility::ContentProfileBean
    end
    it "#get_existing_profile returns nil" do
      expect( @service.send(:get_existing_profile, @auth) ).to be_nil
    end
    it "#get_existing_profile returns found object" do
      expect( @service.content_profile_for_user(user,true) ).to be_a Utility::ContentProfileBean
      expect( @service.send(:get_existing_profile, user) ).to be_a Hash
    end
    it "#encode_userdata_content returns String for String." do
      expect( @service.send(:encode_userdata_content, "Happy") ).to be_kind_of String
    end
    it "#encode_userdata_content returns String for Array." do
      expect( @service.send(:encode_userdata_content, [123,456,789]) ).to be_kind_of String
    end
    it "#encode_userdata_content returns String for Hash." do
      expect( @service.send(:encode_userdata_content, {docTyoe: 955}) ).to be_kind_of String
    end
    it "#create_content_profile_entry returns a one count for items created" do
      parms = {
          "uri"=>"ContentType/TopicType/SomeKey",
          "content_type"=>"ContentType",
          "content_value"=>{:docType=>123, :drawerType=>4312},
          "topic_type"=>"TopicType",
          "topic_value"=>["0034", "0037", "0040"],
          "description"=>"XML Testing Data"
      }
      expect( @service.create_content_profile_entry(parms, false) ).to eq(1)
    end
    it "#create_content_profile_entry returns a three count for items created" do
      parms = {
          "uri"=>"ContentType/TopicType/SomeKey",
          "content_type"=>"ContentType",
          "content_value"=>{:docType=>123, :drawerType=>4312},
          "topic_type"=>"TopicType",
          "topic_value"=>["0034", "0037", "0040"],
          "description"=>"XML Testing Data"
      }
      expect( @service.create_content_profile_entry([parms,parms,parms], false) ).to eq(3)
    end

    it "#destroy_content_profile_entry returns a one count for items deleted" do
      parms = {
          "uri"=>"Commission/Branch/BAD"
      }
      expect( @service.destroy_content_profile_entry(parms, false) ).to eq(1)
    end
  end

  context "Core routines handle not found errors properly. " do

     it "#content_profile_for_user should handle user with no permissions" do
       expect( @service.content_profile_for_user(@auth,true).success ).to be false
     end
    it "#content_profile_for_user should handle :not_found user object" do
      expect( @service.content_profile_for_user(@auth,true).success ).to be false
    end
     it "#content_profile_for_user should handle nil user object" do
       expect( @service.content_profile_for_user(nil,true).success ).to be false
     end
     it "#get_existing_profile should handle nil user." do
       expect{ @service.send(:get_existing_profile, nil) }.to raise_error(Utility::Errors::NotFound)
     end
     it "#encode_userdata_content should handle nil parms." do
       expect( @service.send(:encode_userdata_content, nil) ).to be_nil
     end
     it "#create_content_profile_entry returns a zero count for nil inputs" do
       expect( @service.create_content_profile_entry(nil, false) ).to eq(0)
     end
     it "#destroy_content_profile_entry returns a zero count for nil inputs" do
       expect( @service.destroy_content_profile_entry(nil, false) ).to eq(0)
     end
     it "#create_content_profile_entry returns a zero count for empty inputs" do
       expect( @service.create_content_profile_entry({}, false) ).to eq(0)
     end
     it "#destroy_content_profile_entry returns a zero count for empty inputs" do
       expect( @service.destroy_content_profile_entry({}, false) ).to eq(0)
     end
  end

end
