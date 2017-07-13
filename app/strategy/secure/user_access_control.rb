# lib/Secure/user_access_control.rb
#

module Secure
  module UserAccessControl
    extend ActiveSupport::Concern

    ADMIN_ROLE = SknSettings.security.admin_role

    included do |klass|
      Rails.logger.debug("Secure::UserAccessControl included By #{klass.name}")
    end

    module ClassMethods   # mostly called by Warden
      def security_session_time
        minutes_from_now(SknSettings.security.session_expires.to_i)
      end
      def security_remember_time
        minutes_from_now(SknSettings.security.remembered_for.to_i)
      end
      def minutes_from_now(val=20)
        Time.zone.now.advance(:minutes => val) # val.minutes.from_now
      end

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
        raise ArgumentError, "Invalid Credentials!" unless uname.present?
        upp = nil
        value = self.find_by(username: uname)
        upp = self.new(value) if value.present?
        upp = nil unless upp
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}")
        upp

      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end

      # Warden calls this
      def find_and_authenticate_user(uname, upass)
        raise ArgumentError, "Invalid Credentials!" unless uname.present? and upass.present?
        upp = nil
        value = self.find_by(username: uname).try(:authenticate, upass)
        upp = self.new(value) if value.present?
        upp = nil unless upp
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{upp.present? ? value.name : 'Not Found!'}, CachedKeys: #{count_storage_objects}")
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{uname}) returns: #{e.class.name} msg: #{e.message}")
        # puts e.backtrace
        nil
      end

      # Warden calls this
      def fetch_remembered_user (token=nil)
        raise ArgumentError, "Invalid Credentials!" unless token.present?
        upp = nil
        value = self.find_by(remember_token: token)
        upp = self.new(value) if value.present?
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, #{upp.present? ? upp.name : 'Not Found!'}, CachedKeys: #{count_storage_objects}")
        return nil unless upp && value.token_authentic?(token)
        upp.last_access = Time.zone.now if upp
        upp
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end

      # Warden calls this
      def fetch_cached_user(token)
        raise ArgumentError, "Invalid Credentials!" unless token.present?
        value = retrieve_storage_key(token)
        value.proxy_u.active = false if value.present? and last_login_time_expired?(value)
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{value.present? ? value.name : 'Not Found!'}, State: #{(value && value.proxy_u.active) ? 'Active': 'Not Active[Expired]' }, CachedKeys: #{count_storage_objects}")
        value
      rescue Exception => e
        Rails.logger.error("  #{self.name.to_s}.#{__method__}(#{token}) returns: #{e.class.name} msg: #{e.message}")
        nil
      end
      # Warden calls this or any service
      def logout(token)
        return nil unless token.present?
        u_object = retrieve_storage_key(token.to_sym)
        u_object.disable_authentication_controls if u_object.present?
      end

      def last_login_time_expired?(person)
        return false unless person.present?
        a = (Time.zone.now.to_i - person.last_access.to_i)
        b = (@login_after_seconds ||= SknSettings.security.verify_login_after_seconds.to_i)
        rc = (a > b )
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{person.username}) (A[#{a}] > B[#{b}]) = C[#{rc}]")
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
      opts = (options ? options : user_options)
      rc = Secure::AccessRegistry.check_access_permissions?( self.combined_access_roles, resource_uri, opts)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{opts}")
      rc
    end
    def has_create? (resource_uri, options=nil)
      opts = (options ? options : user_options)
      rc = Secure::AccessRegistry.check_role_permissions?( self.combined_access_roles, resource_uri, "CREATE", opts)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{opts}")
      rc
    end
    def has_read? (resource_uri, options=nil)
      opts = (options ? options : user_options)
      rc = Secure::AccessRegistry.check_role_permissions?( self.combined_access_roles, resource_uri, "READ", opts)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{opts}")
      rc
    end
    def has_update? (resource_uri, options=nil)
      opts = (options ? options : user_options)
      rc = Secure::AccessRegistry.check_role_permissions?( self.combined_access_roles, resource_uri, "UPDATE", opts)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{opts}")
      rc
    end
    def has_delete? (resource_uri, options=nil)
      opts = (options ? options : user_options)
      rc = Secure::AccessRegistry.check_role_permissions?( self.combined_access_roles, resource_uri, "DELETE", opts)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{opts}")
      rc
    end

  end # end AccessControl
end # end Secure
