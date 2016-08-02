

RSpec.describe Builder::InlineValuesAdapter, 'Content Adapter for XML Based AccessRegistry' do

  let(:user) { page_user_developer }
  let(:mc) {ServiceFactoryMockController.new(user: user)}
  let(:service_factory)  { ServiceFactory.new({factory: mc}) }

  before(:each) do
    @factory = service_factory
    @service = @factory.content_adapter_inline_values
  end


  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ Builder::InlineValuesAdapter.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :factory as init param." do
      expect(Builder::InlineValuesAdapter.new({factory: @factory})).to be_a(Builder::InlineValuesAdapter)
    end
    it "#new fails when :factory is invalid." do
      expect{ Builder::InlineValuesAdapter.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#factory.profile_data_services returns a proper service object." do
      expect( @service ).to be_a Builder::InlineValuesAdapter
    end
    it "#service #factory and #controller objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a ServiceFactoryMockController
      expect( @service.factory.controller ).to be_a ServiceFactoryMockController
      expect( @service.controller ).to be_a ServiceFactory
    end
    it "#current_user returns a UserProfile object." do
      expect( @service.factory.current_user ).to be_a Secure::UserProfile
      expect( @service.current_user ).to be_a Secure::UserProfile
    end
    it "#method_missing is not broken by respond_to_missing?." do
      expect( @service.current_user ).to be_a Secure::UserProfile
      expect{ @service.will_not_find_me }.to raise_error(NoMethodError)
      expect{ @service.factory.will_not_find_me }.to raise_error(NoMethodError)
    end
  end

  context "Core methods delivery as designed." do
    let(:cpe) {
                { :id=>"access",
                  :uri=>"LicensedStates/Branch/Operations",
                  :resource_options=>{
                      :uri=>"LicensedStates/Branch/Operations",
                      :role=>"Test.Branch.Operations.LicensedStates.USA",
                      :role_opts=>["0037"]
                  },
                  'content_type' =>"LicensedStates",
                  :content_value=>["21"],
                  :topic_type=>"Branch",
                  :topic_value=>["0037"],
                  :description=>"Partner Relationship Reports",
                  :topic_type_description=>"Partner Relationship Reports",
                  :content_type_description=>"Partner Relationship Reports",
                  :username=>"vptester",
                  :user_options=>["VendorPrimary", "0037"]
                }
    }


    it "#ready? Returns True. " do
      expect( @service.ready?).to be true
    end

    ## Expected Response
    # {:source=>"images", :filename=>"galaxy-man.png", :created=>"2016/02/14", :size=>"3.2 MB"}
    it "#available_content_list returns array of options with descriptions. " do
      expect(  @factory.adapter_for_content_profile_entry(cpe).available_content_list({}) ).to be_a Array
      expect(  @factory.adapter_for_content_profile_entry(cpe).available_content_list(cpe).first ).to be_a(Hash)
    end

    it "#retrieve_content_values returns content_value as is: Array, Hash, or String. " do
      expect(  @factory.adapter_for_content_profile_entry(cpe).retrieve_content_values({}) ).to be_a Array
      expect(  @factory.adapter_for_content_profile_entry(cpe).retrieve_content_values(cpe).first.first ).to be_a(String)
    end

  end


end