##
# lib/factory/object_storage_services.rb
#
# Storage Support for domain and service class
#
module Secure
  module ObjectStorageService
    extend ActiveSupport::Concern

    # Use the name of the class that included us as the storage prefix
    # this will keep it contents private
    #
    # @@object_storage_service_prefix = "Factory"

    # def self.included(base)
    included do 
      # base.class_variable_set(:@@object_storage_service_prefix, base.name.to_s)
      # base.extend StorageClassMethods
    end # end  #included


    module StorageClassMethods
      # @@object_storage_service_prefix = self.name.to_s
      STORAGE_PREFIX = self.name.to_s

      # generate a new unique storage key
      def storage_generate_new_key
        object_store.generate_unique_key
      end
      # tests for keys existence
      def query_storage_key?(storage_key)
        object_store.has_storage_key?(storage_key, STORAGE_PREFIX)
      end
      # returns stored object
      def retrieve_storage_key(storage_key)
        object_store.get_stored_object(storage_key, STORAGE_PREFIX)
      end
      # Saves user object to InMemory Container
      def persist_storage_key(storage_key, obj)
        object_store.add_to_store(storage_key.to_sym, obj, STORAGE_PREFIX)
      end
      # Removes saved user object from InMemory Container
      def release_storage_key(storage_key)
        object_store.remove_from_store(storage_key.to_sym, STORAGE_PREFIX)
      end
      # Returns number of record in cache
      def count_objects_stored()
        object_store.size_of_store(STORAGE_PREFIX)
      end
      def stored_user_profile_keys
        object_store.get_warden_stored_user_profile_keys
      end

      private

      # Purge all over 2 days old
      def self.purge_older_than_two_days()
        object_store.purge_by_seconds() # 2 days is default, else (Time.now - 2.days).to_i
      end

      ##
      # Object Storage Container
      # - keeps a reference to hold object in memory between requests
      def object_store
        Secure::ObjectStorageContainer.instance
      end

    end # end  StorageClassMethods

    #
    # Instance Methods
    #

    # Saves object to inMemory ObjectStore
    # Returns storage key, needed to retrieve
    def save_new_object(obj)
      key = self.storage_generate_new_key()
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) saved as new with key:#{key}")
      self.persist_storage_key(key, obj)
      key
    end

    # Updates existing container with new object reference
    # returns object
    def save_existing_object(key, obj)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) updated existing with key:#{key}")
      self.persist_storage_key(key, obj)
      obj
    end

    # Retrieves object from InMemory Storage
    # returns object
    def get_existing_object(key)
      obj = self.retrieve_storage_key(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) retrieved existing with key:#{key}")
      obj
    end

    # Releases object from InMemory Storage
    # returns object, if present
    def remove_existing_object(key)
      obj = self.release_storage_key(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}(#{obj.class.name}) removed existing object with key:#{key}")
      obj
    end

    # Checks if object is in Storage
    # returns true|false
    def existing_object_stored?(key)
      rc = self.query_storage_key?(key)
      Rails.logger.debug("#{self.name.to_s}.#{__method__}() existing object with key:#{key}, exists?:#{rc ? 'True' : 'False'}")
      rc
    end

  end # end ObjectStorageServices namespace
end # end factory namespace
