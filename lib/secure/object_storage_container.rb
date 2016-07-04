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
      BCrypt::Password.create(token, cost: (BCrypt::Engine::MIN_COST + Settings.security.extra_digest_strength)) # Good and Strong
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
      expired = seconds || (Time.now - 2.days).to_i # as an integer number of seconds since the Epoch.
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
      @objects_storage_container.update({store_key => [object, Time.now.to_i]})
      Rails.logger.debug "  #{self.class.name}.#{__method__}(#{context}) Key=#{store_key.to_s}"
      true # prevent return of full hash
    end

    def get_stored_object(key, context=CDEFAULT)
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

    # Assumes object is a Secure::UserProfile
    # Returns array of arrays where [[key-without-context, username],...]
    def get_warden_stored_user_profile_keys(context=CDEFAULT)
      results = []
      @objects_storage_container.each_pair do |k,v|
        next unless v.first.is_a?(Secure::UserProfile)
        parts = k.to_s.split(".")
        if context.eql?(COVERRIDE)
          results << {parts[1].to_sym => v.first.username}
        elsif parts[0].eql?(context)
          results << {parts[1].to_sym => v.first.username}
        end
      end
      Rails.logger.debug "#{self.class.name}.#{__method__}(#{context}) Results=#{results}"
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

