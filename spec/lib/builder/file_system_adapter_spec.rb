

RSpec.describe Builder::FileSystemAdapter, 'Content Adapter for File Systems' do

  let(:user) { page_user_developer }

  # Mocking methods SF or Service might call on Controller
  def current_user
    user
  end
  def controller
    self
  end

  before(:each) do
    @factory = ServiceFactory.new(factory: self)
    @service = @factory.content_adapter_file_system
  end


  context "Initialization "  do

    it "#new throws an Exception without params." do
      expect{ Builder::FileSystemAdapter.new }.to raise_error(ArgumentError)
    end
    it "#new succeeds with only :factory as init param." do
      expect(Builder::FileSystemAdapter.new({factory: @factory})).to be_a(Builder::FileSystemAdapter)
    end
    it "#new fails when :factory is invalid." do
      expect{ Builder::FileSystemAdapter.new({factory: nil}) }.to raise_error(ArgumentError)
    end
    it "#factory.profile_data_services returns a proper service object." do
      expect( @service ).to be_a Builder::FileSystemAdapter
    end
    it "#service #factory and #controller objects to be different." do
      expect( @service.factory ).to be_a ServiceFactory
      expect( @service.factory.factory ).to be_a self.class
      expect( @service.factory.controller ).to be_a self.class
      expect( @service.controller ).to be_a self.class
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
           {"id"=>"content",
                   "username"=>"aptester",
                   "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
                   "content_type"=>"Commission",
                   "content_value"=>["*.pdf"],
                   "topic_type"=>"Branch",
                   "topic_value"=>["0037"],
                   "description"=>"Determine which branch documents can be seen",
                   "topic_type_description"=>"Branch Actions for a specific branch",
                   "content_type_description"=>"Monthly Commission Reports and Files"
           }
    }
    it "#ready? Returns True. " do
      expect( @service.ready?).to be true
    end

    ## Expected Response
    # {:source=>"images", :filename=>"galaxy-man.png", :created=>"2016/02/14", :size=>"3.2 MB"}
    it "#available_content_list returns array of options with descriptions. " do
      expect( @service.available_content_list({}) ).to be_a Array
      expect( @service.available_content_list(cpe).first ).to be_a(Hash)
    end

    it "#retrieve_content_values returns content_value as is: Array, Hash, or String. " do
      expect( @service.retrieve_content_values({}) ).to be_a Array
      expect( @service.retrieve_content_values(cpe).first ).to be_a(String)
    end

    it "#create_new_content_entry_path returns true on success. " do
      expect( @service.create_new_content_entry_path() ).to be false
      expect( @service.create_new_content_entry_path(cpe, {noop: true}) ).to be true
    end

  end


end