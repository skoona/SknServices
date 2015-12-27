# lib/Secure/access_control.rb
#

module Secure
  module UserAccessControl
    extend ActiveSupport::Concern

    ADMIN_ROLE = Settings.security.admin_role

    included do
      # Todo: Breaks Test User for now
      raise Utility::Errors::SecurityImplementionError,
        "You are missing a critical security vars: :person_authenticated_key, please implement!" unless
          self.attribute_names.include?("person_authenticated_key")
    end

    module ClassMethods   # mostly called by Warden
      # find user in database
      def fetch_remembered_user (token=nil)
        value = self.find_by(remember_token: token)
        value = nil unless value.token_authentic?(token)

        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        value
      end
      # find user from our internal list
      def fetch_cached_user (token)
        value = users_store.get_stored_object(token)

        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        value
      end

      def logout(token)
        user_object = users_store.get_stored_object(token.to_sym)
        user_object.disable_authentication_controls if user_object.present?
      end

      def get_new_secure_digest(token)
        BCrypt::Password.create(token, cost: (BCrypt::Engine::MIN_COST + Settings.security.extra_digest_strength)) # Good and Strong
      end

      def get_new_secure_token
        users_store.generate_unique_key
      end

      def last_login_time_expired?(person)
        rc = (person &&  ((Time.now.to_i - person.updated_at.to_i) > Settings.security.verify_login_after_msecs))
        person.disable_authentication_controls if rc
        rc
      end

      def users_store
        Secure::ObjectStorageContainer.instance
      end
    end

    #
    # Instance Methods
    #

    # returns true/false if any <column>_digest matches token
    # note: Password.new(digest) decrypts digest
    def token_authentic?(token)
      attribute_names.select do |attr|
        attr.split("_").last.eql?("digest") ?
            BCrypt::Password.new(self[attr]).is_password?(token) : false
      end.any?    # any? returns true/false if any digest matched
    end

    def regenerate_remember_token!
      self.generate_unique_token(:remember_token)
      self.remember_token_digest = User.get_new_secure_digest(self.remember_token)
    end

    # Warden will call this methods
    def disable_authentication_controls
      remove_from_store
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
    end

    # Warden will call this methods
    def enable_authentication_controls
      self.try(:setup_access_profile)
      self.try(:setup_content_profile)

      add_to_store
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      true
    end

    ##
    # Application Methods
    # - add more is_<name>? as needed
    #
    def is_admin?
      access_profile.include? ADMIN_ROLE
    end

    ##
    # Core methods
    #

    # Return all Roles
    def access_profile
      self.roles || []
    end
    # Returns RB of ContentProfile
    def content_profile
      self.instance_variable_get(:@content_profile)
    end

    def has_access? (resource_uri, options=nil)
      rc = AccessRegistry.check_access_permissions?( access_profile, resource_uri, options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end

    def has_create? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( access_profile, resource_uri, "CREATE", options)
    end

    def has_read? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( access_profile, resource_uri, "READ", options)
    end

    def has_update? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( access_profile, resource_uri, "UPDATE", options)
    end

    def has_delete? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( access_profile, resource_uri, "DELETE", options)
    end

    # Unpack Groups and Combine with assigned, into roles
    # Called by Warden when user is authenticated
    def setup_access_profile
      role = self.assigned_groups.map do |rg|
        UserGroupRole.list_user_roles(rg)
      end
      if role.present?
        role += self.assigned_roles
        role += self.assigned_groups
        self.roles = role.flatten.uniq
        self.save
      end
    end

    # Retrieves users content profile in ResultBean
    def setup_content_profile
      self.instance_variable_set(:@content_profile,
                                 ContentProfile.find_by_person_authentication_key(self.person_authenticated_key).
                                     try(:profile)
      )
    end

    protected

    # Saves user object to InMemory Container
    def add_to_store()
      Secure::ObjectStorageContainer.instance.add_to_store(person_authenticated_key, self)
    end

    # Removes saved user object from InMemory Container
    def remove_from_store()
      Secure::ObjectStorageContainer.instance.remove_from_store(person_authenticated_key)
    end
  end # end AccessControl
end # end Secure
