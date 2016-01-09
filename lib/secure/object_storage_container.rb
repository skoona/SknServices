##
# <Rails.root>/lib/Secure/object_storage_container.rb
#
## Stores Objects in memory using ThreadSafe methods
#  - keys are expected to be unique and greater than 16 bytes long or (UUIDs)
#  - context is a prefix for keys, which allows multiple caches in same storage container

module Secure
  class ObjectStorageContainer
    include Singleton

    COVERRIDE = "Admin"  # Context Override
    CDEFAULT = "warden"

    def initialize
      @objects_storage_container = Hash.new
    end

    def generate_unique_key
      SecureRandom.hex(16)    # returns a 32 char string
    end

    def remove_from_store(key, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      @objects_storage_container.delete(store_key)
    end

    def add_to_store(key, object, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      @objects_storage_container.update({store_key => object})
    end

    def get_stored_object(key, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      @objects_storage_container.fetch(store_key, nil)
    end

    def has_storage_key?(key, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      @objects_storage_container.key?(store_key)
    end

    def size_of_store(context=CDEFAULT)
      counter = 0
      @objects_storage_container.each_key do |k|
        if context.eql?(COVERRIDE)
          counter += 1
        elsif k.to_s.starts_with?(context)
          counter += 1
        end
      end
      counter
    end

    def stored_keys(context='warden')
      results = []
      @objects_storage_container.each_pair do |k,v|
        parts = k.to_s.split(".")
        if context.eql?(COVERRIDE)
          results << {parts[1].to_sym => v.username}
        elsif parts[0].eql?(context)
          results << {parts[1].to_sym => v.username}
        end
      end
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

