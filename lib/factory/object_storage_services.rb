##
# lib/factory/object_storage_services.rb
#
# Storage Support for domain and service class
#
module Factory
  module ObjectStorageServices

    # Use the name of the class that included us as the storage prefix
    # this will keep it contents private
    #
    @object_storage_service_prefix = "Factory"

    def self.included(mod)
      @object_storage_service_prefix = mod.name.to_s
    end

    #
    # Instance Methods
    #


    protected

    STORAGE_PREFIX="System"

    #
    # Core Access Routines
    #

    # generate a new unique storage key
    def storage_generate_new_key
      object_store.generate_unique_key
    end
    # tests for keys existence
    def query_storage_key?(storage_key)
      object_store.has_storage_key?(storage_key, @object_storage_service_prefix)
    end
    # returns stored object
    def retrieve_storage_key(storage_key)
      object_store.get_stored_object(storage_key, @object_storage_service_prefix)
    end
    # Saves user object to InMemory Container
    def persist_storage_key(storage_key, obj)
      object_store.add_to_store(storage_key.to_sym, obj, @object_storage_service_prefix)
    end
    # Removes saved user object from InMemory Container
    def release_storage_key(storage_key)
      object_store.remove_from_store(storage_key.to_sym, @object_storage_service_prefix)
    end

    private

    ##
    # Object Storage Container
    # - keeps a reference to hold object in memory between requests
    def object_store
      Secure::ObjectStorageContainer.instance
    end

  end # end ObjectStorageServices namespace
end # end factory namespace
