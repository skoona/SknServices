# lib/Secure/access_control.rb
#

module Secure
  module AccessControl
    extend ActiveSupport::Concern

    ADMIN_ROLE = Settings.security.admin_role

    included do |target|

    #   puts "Roles" unless target.respond_to?(:roles)
    #   puts "assigned_roles" unless target.respond_to?(:assigned_roles)
    #   puts "assigned_groups" unless target.respond_to?(:assigned_groups)
    #   puts "person_authenticated_key" unless target.respond_to?(:person_authenticated_key)
    #
    #   raise(Utility::Errors::SecurityRoleNotImplementedError, %Q-[AccessControl]
    #      Required instance vars missing: @roles, @assigned_roles, and assigned_groups.
    #      Vars must be implemented/assigned in the class #{target} that includes this module!- ) unless
    #         target.respond_to?(:roles) and
    #           target.respond_to?(:assigned_roles) and
    #           target.respond_to?(:assigned_groups) and
    #           target.respond_to?(:person_authenticated_key)
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
      else
        self.roles=[]
      end
    end

    # Retrieves users content profile in ResultBean
    def setup_content_profile
      self.instance_variable_set(:@content_profile,
        ContentProfile.find_by_person_authentication_key(self.person_authenticated_key).
          try(:profile)
      )
    end

  end
end
