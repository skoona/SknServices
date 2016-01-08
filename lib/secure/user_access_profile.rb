# lib/Secure/user_access_profile.rb
#

module Secure
  module UserAccessProfile
    extend ActiveSupport::Concern

    ADMIN_ROLE = Settings.security.admin_role

    included do

      # raise Utility::Errors::SecurityImplementionError,
      #   "You are missing a critical security var: :person_authenticated_key; Please implement!" unless
      #     self.attribute_names.include?("person_authenticated_key")
    end

    module ClassMethods   # mostly called by Warden

      # AccessProfile will call this
      def page_users(context='access')
        usrs = []
        self.where(active: true).find_each do |u|
          usrs << Secure::UserProfile.new(u).enable_authentication_controls(true)
        end
        usrs
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}() returns: #{e.class.name} msg: #{e.message}")
        []
      end

      # AccessProfile will call this
      def page_user(uname, context='access')
        upp = nil
        value = self.find_by(username: uname)
        upp = self.new(value).enable_authentication_controls(true) if value.present?
        upp = nil unless upp && value
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        upp

      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end

      # find user in database
      def find_and_authenticate_user(uname, upass)
        upp = nil
        value = self.find_by(username: uname).authenticate(upass)
        upp = self.new(value) if value.present?
        upp = nil unless upp && value
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      def fetch_remembered_user (token=nil)
        upp = nil
        value = self.find_by(remember_token: token)
        upp = self.new(value) if value.present?
        upp = nil unless upp && value && value.token_authentic?(token)
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        upp.last_access = Time.now if upp
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      # find user from our internal list
      def fetch_cached_user (token)
        value = users_store.get_stored_object(token)
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, CachedKeys: #{users_store.size_of_store}:#{users_store.stored_keys}")
        value
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end

      def logout(token)
        u_object = users_store.get_stored_object(token.to_sym)
        u_object.disable_authentication_controls if u_object.present?
      end

      def get_new_secure_digest(token)
        BCrypt::Password.create(token, cost: (BCrypt::Engine::MIN_COST + Settings.security.extra_digest_strength)) # Good and Strong
      end

      def get_new_secure_token
        users_store.generate_unique_key
      end

      def last_login_time_expired?(person)
        a = (Time.now.to_i - person.last_access.to_i)
        b = Settings.security.verify_login_after_msecs.to_i / 1000
        rc = (person &&  (a > b ))
        person.last_access = Time.now
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{person.username if person}) (A[#{a}] > B[#{b}]) = C[#{rc}]")
        rc
      end

      def users_store
        Secure::ObjectStorageContainer.instance
      end
    end

    #
    # Instance Methods
    #


    # Warden will call this methods
    def disable_authentication_controls(prepare_only=false)
      self.last_access = Time.now
      proxy_u.save
      remove_from_store unless prepare_only
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      true
    end

    # Warden will call this methods
    def enable_authentication_controls(prepare_only=false)
      self.last_access = Time.now
      self.setup_access_profile
      self.setup_content_profile

      add_to_store unless prepare_only
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      true
    end

    ##
    # Core methods
    #

    # Return all Roles
    def access_roles_all()
      proxy_u.roles || []
    end

    def access_profile
      Utility::UserContentProfileBean.new({
              entries: get_resource_content_entries() || [],
              pak: person_authenticated_key,
              profile_type: "",
              profile_type_description: "",
              provider: "UserProfile",
              username: username,
              display_name: display_name,
              email: email
          })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      {}
    end

    # Unpack Groups and Combine with assigned, into roles
    # Called by Warden when user is authenticated
    def setup_access_profile
      rc = false
      role = proxy_u[:assigned_groups].map do |rg|
        UserGroupRole.list_user_roles(rg)
      end
      if role.present?
        role += proxy_u[:assigned_roles]
        role += proxy_u[:assigned_groups]
        proxy_u[:roles] = role.flatten.uniq
        rc = proxy_u.save
      end
      rc
    end

    def is_admin?
      access_roles_all.include? ADMIN_ROLE
    end

    def has_access? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_access_permissions?( access_roles_all, resource_uri, options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end

    def has_create? (resource_uri, options=nil)
      Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "CREATE", options)
    end

    def has_read? (resource_uri, options=nil)
      Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "READ", options)
    end

    def has_update? (resource_uri, options=nil)
      Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "UPDATE", options)
    end

    def has_delete? (resource_uri, options=nil)
      Secure::AccessRegistry.check_role_permissions?( access_roles_all, resource_uri, "DELETE", options)
    end

    def get_resource_description(resource_uri)
      Secure::AccessRegistry.get_resource_description(resource_uri)
    end
    def get_resource_userdata(resource_uri)
      Secure::AccessRegistry.get_resource_userdata(resource_uri)
    end
    def get_resource_content_entries(opt=nil)
      opts = opt || self[:user_options] || nil
      Secure::AccessRegistry.get_resource_content_entries(self[:roles], opts)
    end
    def get_resource_content_entry(resource_uri, opt=nil)
      opts = opt || self[:user_options] || nil
      Secure::AccessRegistry.get_resource_content_entry(self[:roles], resource_uri,  opts)
    end

    protected

    # Saves user object to InMemory Container
    def add_to_store()
      Secure::ObjectStorageContainer.instance.add_to_store(person_authenticated_key.to_sym, self)
    end

    # Removes saved user object from InMemory Container
    def remove_from_store()
      Secure::ObjectStorageContainer.instance.remove_from_store(person_authenticated_key.to_sym)
    end
  end # end AccessControl
end # end Secure
