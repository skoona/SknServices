module TestProviders
  class DocumentProvider < Factory::ServicesBase
    attr_accessor :key, :obj
    def initialize
      @obj = SknUtils::ResultBean.new({samples: "samples", quanity: 3, values: [22, 16, 55]})
      @key = []
    end

    def self.class_storage_context
      oscs_get_context
    end

    def save
      @key << create_storage_key_and_store_object(obj)
      @key.last
    end
    def find(key_id=nil)
      value = key_id || key.first
      get_storage_object(value)
    end
    def storage_context
      singleton_class.class_storage_context
    end

  end

  class ImageProvider < Factory::ServicesBase
    attr_accessor :key, :obj
    def initialize
      @obj = SknUtils::ResultBean.new({samples: "samples", quanity: 2, values: [55, 22]})
      @key = []
    end

    def self.class_storage_context
      oscs_get_context
    end

    def save
      @key << create_storage_key_and_store_object(obj)
      @key.last
    end
    def find(key_id=nil)
      value = key_id || key.first
      get_storage_object(value)
    end
    def storage_context
      singleton_class.class_storage_context
    end

  end
end

RSpec.describe 'Inherited Factory Base Services' do

  before(:each) do
    Secure::ObjectStorageContainer.instance.test_reset!
  end

  it 'Maintain separate contexts.' do
    provider_one = TestProviders::DocumentProvider.new()
    provider_two = TestProviders::ImageProvider.new()
    expect(provider_one.storage_context).not_to eq(provider_two.storage_context)
  end

  it 'Provide unique save keys.' do
    provider_one = TestProviders::DocumentProvider.new()
    provider_two = TestProviders::ImageProvider.new()
    k1 = provider_one.save
    k2 = provider_two.save
    expect(k1).not_to eq(k2)
  end

  it 'Reports saved object counts by context.' do
    provider_one = TestProviders::DocumentProvider.new()
    provider_two = TestProviders::ImageProvider.new()
    u = Secure::UserProfile.find_and_authenticate_user("vstester", "nobugs").enable_authentication_controls
    k1 = provider_one.save
    k2 = provider_two.save
    expect(TestProviders::DocumentProvider.count_storage_objects).to eq(1)
    expect(TestProviders::ImageProvider.count_storage_objects).to eq(1)
    expect(Secure::UserProfile.count_storage_objects).to eq(1)
    expect(TestProviders::ImageProvider.count_storage_objects("Admin")).to eq(3)
  end

  it 'Restores saved objects by key using default context' do
    provider_one = TestProviders::DocumentProvider.new()
    provider_two = TestProviders::ImageProvider.new()
    k1 = provider_one.save
    k2 = provider_two.save
    expect(provider_one.find(k1)).to equal(provider_one.obj)
    expect(provider_two.find(k2)).to equal(provider_two.obj)
  end

end