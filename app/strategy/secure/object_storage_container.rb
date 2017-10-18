##
# <Rails.root>/lib/Secure/object_storage_container.rb
#
## Stores Objects in memory using ThreadSafe methods
#  - keys are expected to be unique and greater than 16 bytes long or (UUIDs)
#    * generate_new_key() produces a 32 char UUID
#  - context is a prefix for keys, which allows multiple caches in same storage container
#  - The internal storage template is: {key: [object, timestamp]}
#    * The timestamp allows for later cleanup if needed
# 
# -- Maybe and Alternate Utility
# Ref: http://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-store

module Secure
  class ObjectStorageContainer
    include Singleton

    COVERRIDE = "Admin"  # Context Override
    CDEFAULT =  "Warden"

    def initialize
      Rails.logger.debug("Secure::ObjectStorageContainer => #{self.class.name} initialized.")
      @objects_storage_container = Hash.new
    end

    def generate_unique_key
      SecureRandom.hex(16)    # returns a 32 char string
    end
    def get_new_secure_digest(token)
      BCrypt::Password.create(token, cost: (BCrypt::Engine::MIN_COST + SknSettings.security.extra_digest_strength)) # Good and Strong
    end

    def remove_from_store(key, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      rc = @objects_storage_container.key?(store_key) ? @objects_storage_container.delete(store_key).first : nil
      Rails.logger.debug "#{self.class.name}.#{__method__}(#{context}) Key=#{store_key.to_s}"
      rc
    end

    # Remove all entries more than two days old
    # Returns count removed
    def purge_by_seconds(seconds=nil)
      counter = 0
      expired = seconds || (Time.zone.now - 2.days).to_i # as an integer number of seconds since the Epoch.
      @objects_storage_container.delete_if do |k,v|
        if v.last < expired
          counter += 1
          true
        else
          false
        end
      end
      Rails.logger.perf "#{self.class.name}.#{__method__}() Count=#{counter}"
      counter
    end

    def add_to_store(key, object, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      @objects_storage_container.update({store_key => [object, Time.zone.now.to_i]})
      Rails.logger.debug "  #{self.class.name}.#{__method__}(#{context}) Key=#{store_key.to_s}"
      true # prevent return of full hash
    end

    def get_storage_object(key, context=CDEFAULT)
      store_key = "#{context}.#{key.to_s}".to_sym
      rc = @objects_storage_container.key?(store_key) ? @objects_storage_container[store_key].first : nil
      Rails.logger.debug "  #{self.class.name}.#{__method__}(#{context}) Key=#{store_key.to_s}"
      rc
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
      Rails.logger.debug "  #{self.class.name}.#{__method__}(#{context}) KeyCount=#{counter}"
      counter
    end

    #
    # Returns array of arrays where [[key-without-context, username],...]
    def list_storage_keys_and_value_class()
      results = []
      @objects_storage_container.each_pair do |k,v|
        name = v.first.try(:username) || v.first.try(:[], :username) || "not found"
        parts = k.to_s.split('.')
          results << {
              klass: parts[0],
              key: parts[1],
              vklass: v.first.class.name,
              ref: name,
              time: Time.at(v.last).strftime("%Y-%m-%d %H:%M:%S %p")
          }
      end
      Rails.logger.debug "#{self.class.name}.#{__method__}() Results=#{results.count}"
      results
    end

    ##
    # Test Support -- Clear without delay
    def test_reset!
      @objects_storage_container.clear
      true
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

