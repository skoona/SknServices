##
# lib/factory/object_storage_services.rb
#
# Storage Support for domain and service class
#
module Secure

  module ObjectStorageService
    def included(mod)
      Rails.logger.debug("ObjectStorageService => #{self.name} included By #{mod.name}")
      @@object_storage_service_prefix = mod.name
      class << self.singleton_class
        ##
        # Class Methods
        #

        # generate a new unique storage key
        def self.storage_generate_new_key
          object_store.generate_unique_key
        end

        # tests for keys existence
        def self.query_storage_key?(storage_key)
          object_store.has_storage_key?(storage_key, @@object_storage_service_prefix)
        end

        # returns stored object
        def self.retrieve_storage_key(storage_key)
          object_store.get_stored_object(storage_key, @@object_storage_service_prefix)
        end

        # Saves user object to InMemory Container
        def self.persist_storage_key(storage_key, obj)
          object_store.add_to_store(storage_key.to_sym, obj, @@object_storage_service_prefix)
        end

        # Removes saved user object from InMemory Container
        def self.release_storage_key(storage_key)
          object_store.remove_from_store(storage_key.to_sym, @@object_storage_service_prefix)
        end

        # Returns number of record in cache
        def self.count_objects_stored
          object_store.size_of_store(@@object_storage_service_prefix)
        end

        def self.stored_user_profile_keys
          object_store.get_warden_stored_user_profile_keys
        end

        # private

        # Purge all over 2 days old
        def self.purge_older_than_two_days
          object_store.purge_by_seconds # 2 days is default, else (Time.now - 2.days).to_i
        end

        ##
        # Object Storage Container
        # - keeps a reference to hold object in memory between requests
        def self.object_store
          Secure::ObjectStorageContainer.instance
        end
      end
    end
    ##
    # Instance Methods
    #


    # Saves object to inMemory ObjectStore
    # Returns storage key, needed to retrieve
    def save_new_object(obj)
      key = storage_generate_new_key()
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) saved as new with key:#{key}")
      persist_storage_key(key, obj)
      key
    end

    # Updates existing container with new object reference
    # returns object
    def save_existing_object(key, obj)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) updated existing with key:#{key}")
      persist_storage_key(key, obj)
      obj
    end

    # Retrieves object from InMemory Storage
    # returns object
    def get_existing_object(key)
      obj = retrieve_storage_key(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) retrieved existing with key:#{key}")
      obj
    end

    # Releases object from InMemory Storage
    # returns object, if present
    def remove_existing_object(key)
      obj = release_storage_key(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) removed existing object with key:#{key}")
      obj
    end

    # Checks if object is in Storage
    # returns true|false
    def existing_object_stored?(key)
      rc = query_storage_key?(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}() existing object with key:#{key}, exists?:#{rc ? 'True' : 'False'}")
      rc
    end

    def self.extended(base)
      Rails.logger.debug("ObjectStorageService => #{self.name} extended by #{base.name}")
    end
    def self.included(base)
      Rails.logger.debug("ObjectStorageService => #{self.name} included by #{base.name}")
    end

  end # end ObjectStorageService namespace

end # end factory namespace
