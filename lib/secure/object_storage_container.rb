##
# <Rails.root>/lib/Secure/object_storage_container.rb
#
## Stores Objects in memory using ThreadSafe methods
#  - keys are expected to be unique and greater than 16 bytes long or (UUIDs)
#

module Secure
  class ObjectStorageContainer
    include Singleton

    def initialize
      @objects_storage_container = Hash.new
    end

    def generate_unique_key
      SecureRandom.hex(16)    # returns a 32 char string
    end

    def remove_from_store(key)
      @objects_storage_container.delete key.to_s.to_sym
    end

    def add_to_store(key, object)
      @objects_storage_container.update({key.to_s.to_sym => object})
    end

    def get_stored_object(key)
      @objects_storage_container.fetch(key.to_s.to_sym, nil)
    end

    def has_storage_key?(key)
      @objects_storage_container.key? key.to_s.to_sym
    end
    def size_of_store
      @objects_storage_container.size
    end
    def stored_keys
      results = []
      @objects_storage_container.each_pair {|k,v| results << {k => v.username}}
      results
    end

    ##
    # Marshalling Support to preserve state of objects_storage_container
    #
    def _dump(depth=-1)
      Marshal.dump(@objects_storage_container, depth)
    end

    def self._load(str)
      instance.reload_store Marshal.load(str)
      instance
    end

    def reload_store(store)
      @objects_storage_container = store
    end
  end
end

