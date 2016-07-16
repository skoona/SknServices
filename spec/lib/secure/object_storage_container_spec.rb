
RSpec.describe Secure::ObjectStorageContainer, "Singleton for use as object cache " do

  let(:object_store) {Secure::ObjectStorageContainer.instance}

  it "#new raises an exception" do
    expect{ Secure::ObjectStorageContainer.new }.to raise_error(NoMethodError)
  end

  it "#generate_unique_key returns a string value" do
    expect(object_store.generate_unique_key).to_not be_nil
    expect(object_store.generate_unique_key).to be_a String
    expect(object_store.generate_unique_key.size).to be == 32
  end

  it "#instance always returns the same object" do
    obj1 = Secure::ObjectStorageContainer.instance
    obj2 = Secure::ObjectStorageContainer.instance
    expect(obj1.object_id).to be_eql obj2.object_id
  end

  it "#add_to_store stores an object" do
    count = object_store.size_of_store
    objectx = AccessRegistryTestUser.new

    object_store.add_to_store(objectx.key, objectx)
    expect(object_store.size_of_store).to be == count + 1
  end

  it "#remove_from_store removes the saved object" do
    count = object_store.size_of_store
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)
    expect(object_store.size_of_store).to be == count + 1

    object_store.remove_from_store(objectx.key)
    expect(object_store.size_of_store).to be == count
  end
  it "#remove_from_store survives requests to remove same object twice" do
    count = object_store.size_of_store
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)
    expect(object_store.size_of_store).to be == count + 1

    expect(object_store.remove_from_store(objectx.key)).to be_eql objectx
    expect(object_store.remove_from_store(objectx.key)).to be_nil

    expect(object_store.size_of_store).to be == count
  end

  it "#get_storage_object returns the requested object" do
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)

    expect(object_store.get_storage_object(objectx.key)).to be_eql objectx
  end
  it "#get_storage_object returns nil when requested object is not found" do
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)

    expect(object_store.get_storage_object("sample entry that cannot be found")).to be_nil
  end

  it "#has_storage_key? return true/false according to presence of requested symbol key" do
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)

    expect(object_store.has_storage_key?(objectx.key.to_sym)).to be true
    expect(object_store.has_storage_key?("SomeBodyHelpMePlease".to_sym)).to be false
  end
  it "#has_storage_key? return true/false according to presence of requested string key" do
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)

    expect(object_store.has_storage_key?(objectx.key)).to be true
    expect(object_store.has_storage_key?("SomeBodyHelpMePlease")).to be false
  end

  it "#size_of_store returns a count of the number of object present in store" do
    count = object_store.size_of_store
    objectx = AccessRegistryTestUser.new
    object_store.add_to_store(objectx.key, objectx)
    expect(object_store.size_of_store).to be == count + 1
  end

  it "#Marshal.dump/_load saves the object with current state intact" do
    count = object_store.size_of_store
    objectx = AccessRegistryTestUser.new
    objecty = AccessRegistryTestUser.new

    object_store.add_to_store(objectx.key, objectx)
    object_store.add_to_store(objecty.key, objecty)
    expect(object_store.size_of_store).to be == count + 2

    thingy = Marshal.dump(object_store)       # will not marshal stubs of any sort!!!
    restored = Marshal.load(thingy)
    expect(restored.has_storage_key?(objectx.key)).to be true
  end

end
