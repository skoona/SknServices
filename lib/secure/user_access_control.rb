# lib/Secure/user_access_control.rb
#

module Secure
  module UserAccessControl
    extend ActiveSupport::Concern

    ADMIN_ROLE = Settings.security.admin_role

    module ClassMethods   # mostly called by Warden

      # AccessProfile will call this
      def page_users(context='access')
        usrs = []
        self.where(active: true).find_each do |u|
          usrs << Secure::UserProfile.new(u)
        end
        usrs
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}() returns: #{e.class.name} msg: #{e.message}")
        []
      end

      # ContentProfile will call this
      def page_user(uname, context='access')
        upp = nil
        value = self.find_by(username: uname)
        upp = self.new(value) if value.present?
        upp = nil unless upp && value
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{count_objects_stored}:#{stored_user_profile_keys}")
        upp

      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end

      # Warden calls this
      def find_and_authenticate_user(uname, upass)
        upp = nil
        value = self.find_by(username: uname).authenticate(upass)
        upp = self.new(value) if value.present?
        upp = nil unless upp && value
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{count_objects_stored}:#{stored_user_profile_keys}")
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      # Warden calls this
      def fetch_remembered_user (token=nil)
        upp = nil
        value = self.find_by(remember_token: token)
        upp = self.new(value) if value.present?
        upp = nil unless upp && value && value.token_authentic?(token)
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{count_objects_stored}:#{stored_user_profile_keys}")
        upp.last_access = Time.now if upp
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      # Warden calls this
      def fetch_cached_user (token)
        value = retrieve_storage_key(token)
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, CachedKeys: #{count_objects_stored}:#{stored_user_profile_keys}")
        value
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      # Warden calls this or any service
      def logout(token)
        u_object = retrieve_storage_key(token.to_sym)
        u_object.disable_authentication_controls if u_object.present?
      end

      def last_login_time_expired?(person)
        a = (Time.now.to_i - person.last_access.to_i)
        b = Settings.security.verify_login_after_seconds.to_i
        rc = (person &&  (a > b ))
        person.last_access = Time.now
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{person.username if person}) (A[#{a}] > B[#{b}]) = C[#{rc}]")
        rc
      end
    end # end class methods

    #
    # Instance Methods
    #

    def is_admin?
      combined_access_roles.include? ADMIN_ROLE
    end

    def has_access? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_access_permissions?( combined_access_roles, resource_uri, options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end
    def has_create? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_role_permissions?( combined_access_roles, resource_uri, "CREATE", options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end
    def has_read? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_role_permissions?( combined_access_roles, resource_uri, "READ", options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end
    def has_update? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_role_permissions?( combined_access_roles, resource_uri, "UPDATE", options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end
    def has_delete? (resource_uri, options=nil)
      rc = Secure::AccessRegistry.check_role_permissions?( combined_access_roles, resource_uri, "DELETE", options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end

  end # end AccessControl
end # end Secure
