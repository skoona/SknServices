##
# lib/factory/object_storage_services.rb
#
# Object Storage Support for domain and service classes
#
module Factory

  module ObjectStorageService
    extend ActiveSupport::Concern

    included do |klass|
        Rails.logger.debug("Factory::ObjectStorageService => #{self.name} included By #{klass.name}")
    end

    ##
    # Class Methods
    #
    module ClassMethods
      @@object_storage_service_prefix = nil

      # protected

      # generate a new unique storage key
      def storage_generate_new_key
        object_store.generate_unique_key
      end

      # tests for keys existence
      def query_storage_key?(storage_key)
        object_store.has_storage_key?(storage_key, oscs_get_context)
      end

      # returns stored object
      def retrieve_storage_key(storage_key)
        object_store.get_stored_object(storage_key, oscs_get_context)
      end

      # Saves user object to InMemory Container
      def persist_storage_key(storage_key, obj)
        object_store.add_to_store(storage_key.to_sym, obj, oscs_get_context)
      end

      # Removes saved user object from InMemory Container
      def release_storage_key(storage_key)
        object_store.remove_from_store(storage_key.to_sym, oscs_get_context)
      end

      # Returns number of record in cache
      def count_objects_stored(ctx=nil)
        context = ctx || oscs_get_context
        object_store.size_of_store(context)
      end

      def stored_user_profile_keys
        object_store.get_warden_stored_user_profile_keys(oscs_get_context)
      end

      # Purge all over 2 days old
      def purge_older_than_two_days(seconds=nil)
        object_store.purge_by_seconds(seconds) # 2 days is default, else (Time.now - 2.days).to_i
      end

      protected

      def oscs_get_context
        class_variable_get(:@@object_storage_service_prefix)
      end
      def oscs_set_context=(str_val)
        class_variable_set(:@@object_storage_service_prefix, str_val)
      end

      ##
      # Object Storage Container
      # - keeps a reference to hold object in memory between requests
      def object_store
        Secure::ObjectStorageContainer.instance
      end
    end # ClassMethods module


    ##
    # Instance Methods
    #

    # Saves object to inMemory ObjectStore
    # Returns storage key, needed to retrieve
    def create_storage_key_and_store_object(obj)
      key = singleton_class.storage_generate_new_key()
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}(#{obj.class.name}) saved as new with key:#{key}")
      singleton_class.persist_storage_key(key, obj)
      key
    end

    # Updates existing container with new object reference
    # returns object
    def update_stored_object(key, obj)
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{obj.class.name}) updated existing with key:#{key}")
      singleton_class.persist_storage_key(key, obj)
      obj
    end

    # Retrieves object from InMemory Storage
    # returns object
    def get_stored_object(key)
      obj = singleton_class.retrieve_storage_key(key)
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{obj.class.name}) retrieved existing with key:#{key}")
      obj
    end

    # Releases object from InMemory Storage
    # returns object, if present
    def delete_stored_object(key)
      obj = singleton_class.release_storage_key(key)
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}(#{obj.class.name}) removed existing object with key:#{key}")
      obj
    end

    # Checks if object is in Storage
    # returns true|false
    def is_object_stored?(key)
      rc = singleton_class.query_storage_key?(key)
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() existing object with key:#{key}, exists?:#{rc ? 'True' : 'False'}")
      rc
    end

  end # end ObjectStorageService namespace

end # end factory namespace
