# lib/Secure/access_control.rb
#

module Secure
  module AccessControl
    extend ActiveSupport::Concern

    ADMIN_ROLE = Settings.security.admin_role
    SMSG = %Q#[AccessControl] Required instance variable missing: @roles. A '@roles' variable must be implemented/assigned 
               in the class that includes this module!#

    included do |target|
      target.instance_variable_set("@roles", []) unless  target.instance_variable_defined?(:@roles)
      raise(Utility::Errors::SecurityRoleNotImplementedError, SMSG) unless  target.instance_variable_defined?(:@roles)
    end

    def user_roles
      x = roles || []
      x = [x] unless x.is_a?Array
      x
    end

    ##
    # Application Methods
    # - add more is_<name>? as needed
    #
    def is_admin?
      user_roles.include? ADMIN_ROLE
    end

    ##
    # Core methods
    #
    def has_access? (resource_uri, options=nil)
      rc = AccessRegistry.check_access_permissions?( user_roles, resource_uri, options)
      Rails.logger.debug("#{self.class.name}.#{__method__}(#{rc ? 'True':'False'}) #{resource_uri} #{options}")
      rc
    end

    def has_create? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( user_roles, resource_uri, "CREATE", options)
    end

    def has_read? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( user_roles, resource_uri, "READ", options)
    end

    def has_update? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( user_roles, resource_uri, "UPDATE", options)
    end

    def has_delete? (resource_uri, options=nil)
      AccessRegistry.check_role_permissions?( user_roles, resource_uri, "DELETE", options)
    end

  end
end
