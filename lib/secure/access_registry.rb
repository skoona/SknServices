##
# app/services/access_registry.rb
#
# Reads a control file from <rails_root>/config/access_registry.xml into a control hash
# offers static routines to callers which validate access to controlled resources
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 2/27/2013
##
#
# The intentions of this module is to control permissions for all of the app in the following ways.
# - 1. Global Action (Clickables) Permissions
# - 2. Page Access
# - 3. Page Action Permission
# - 4. Content Access Permissions
#
# A possible Role Scheme could be:
#  Role: 1. 'Global.<actionName>'
#        2. 'Global.<PageName>'
#        3. '<PageName>.<actionName>'
#        4. 'Content.<contentName>.<accessAction>'
#
# A possible URI scheme could be:
#  URI: 1. 'Global.<actionName>'
#       2. '<controller>/<actionName>'  or '<menuName>/<controllerName>'
#       3. '<pageName>.<actionName>'
#       4. '<contentName>.<accessAction>'
#
# A possible Content Access scheme could be:
#     <resource secured="true" content="true">
#       <uri>Commission/Branch/PDF</uri>'                     Todo: ContentType/TopicType/AssetType
#       <description>Branch Commission Statements</description>
#       <userdata>string, array, or hash content_value_opts</userdata>'   Todo: keys to the content
#       <permission type="READ">'
#         <authorizedRoles>         Todo: options contain comma-separated list of all agencies
#           <authorizedRole options="0034,0037,0040">Branch.Commission.Access</authorizedRole>
#         </authorizedRoles>
#       </permission>'
#     </resource>
#
#     <resource secured="true" content="true">
#       <uri>Commission/Branch/CSV</uri>'                     Todo: ContentType/TopicType/AssetType
#       <description>Branch Commission CSV Datafiles</description>
#       <userdata>string, array, or hash content_value_opts</userdata>'   Todo: keys to the content
#       <permission type="READ">'
#         <authorizedRoles>         Todo: options contain comma-separated list of all agencies
#           <authorizedRole options="0034,0037,0040">Branch.Commission.Access</authorizedRole>
#         </authorizedRoles>
#       </permission>'
#     </resource>
#
#     <resource secured="true" content="true">
#       <uri>Experience/Branch/PDF</uri>'                     Todo: ContentType/TopicType/AssetType
#       <description>Branch Experience Statements</description>
#       <userdata>string, array, or hash content_value_opts</userdata>'   Todo: keys to the content
#       <permission type="READ">'
#         <authorizedRoles>         Todo: options contain comma-separated list of all agencies
#           <authorizedRole options="0034,0037,0040">Branch.Commission.Access</authorizedRole>
#         </authorizedRoles>
#       </permission>'
#     </resource>
#
# The User profile object has methods to facilitate access queries; via the
##
#   <APPLICATION-PROTECTED-RESOURCE-URI>  <-- mapping --> <EXTERNALLY CONTROLLED ROLE NAME>
#   ================================================================================
# A) Each clickable or protected resource in the application is given an id or URI name, when created in 
#    the application.  This name is absolutely unique to the protected resource, and must be assigned by the 
#    developer/designer.
#
# B) The Secure::AccessRegistry maps this name to an unique security role name, which reflects the intent or content
#    of the protected resource.  While mapping the two URIs, additional attributes are available for
#    assignment to clarify the relationship and/or mapping.  Attributes like the classic CREATE/READ/UPDATE/DELETE,
#    and other attributes which could convey more restrictive access and ownership permissions.
#
# C) The full security implementation automatically verifies access to Page or Controller/Action resources.  All
#    other authorization controls must be implemented by the developer using #has_access?|??? methods provided.
##


## control hash structure
#
#  access_registry = {
#    "uri" = {
#      "secured" => true,
#      "content" => true,
#      "description" => "some description",
#      "READ" => {
#        "role name" => ["options","options",...],        
#        "role n" => []
#      }
#    }, ...
#  }
#

module Secure
  class AccessRegistry

    CRUD_MODES = ["CREATE","READ","UPDATE","DELETE"].freeze
    @@ar_permissions = (
        Secure::AccessRegistryUtility.new(Settings.access_profile.access_registry_filename.basename).from_xml().merge(
          Secure::AccessRegistryUtility.new(Settings.access_profile.content_registry_filename.basename, 'contentRegistry').from_xml())
    )
    @@ar_strict_mode = Settings.access_profile.default_unknown_to_unsecure

    def initialize
      # not needed as this is a static class
      raise NotImplementedError, "Do Not Instantiate this class"
    end

    ##
    # Core Methods
    #
    def self.get_crud_modes
      CRUD_MODES
    end
    def self.get_resource_description(resource_uri)
      @@ar_permissions.key?(resource_uri) ? @@ar_permissions[resource_uri][:description] : ""
    end
    def self.get_resource_type(resource_uri)
      @@ar_permissions.key?(resource_uri) ? @@ar_permissions[resource_uri][:content] : false
    end
    def self.get_resource_userdata(resource_uri)
      @@ar_permissions.key?(resource_uri) ? @@ar_permissions[resource_uri][:userdata] : ""
    end

    def self.get_ar_resource_keys
      @@ar_permissions.keys
    end
    def self.get_ar_permissions_hash
      @@ar_permissions
    end

    ##
    # Match specific CRUD
    # User Role MUST match CRUD Role AND
    # User options MUST match Resource Options if Resource Options are present
    def self.check_role_permissions? (user_roles, resource_uri, crud_mode="READ", options=nil)
      user_roles = [user_roles] unless user_roles.kind_of?(Array)
      result = false

      if is_secured? resource_uri then
        result = catch :found do
          user_roles.each do |user_role|
            result  = role_in_resource_crud?(user_role, resource_uri, crud_mode)
            #puts "\tCHECK_ROLE_PERMISSIONS?(#{user_role}->#{crud_mode}) returned=#{result}"
            next unless result
            opts    = has_options_ary?(user_role,resource_uri,crud_mode)
            result  = role_in_resource_crud_with_option?(user_role,resource_uri,crud_mode,options) if opts
            #puts "\t\tCHECK_ROLE_PERMISSIONS?(#{crud_mode}) returned=#{result}"
            throw :found, true if result
          end # end user roles
          false    # false if nothing  is thrown, i.e not found
        end # end catch
      else
        # TODO: Enable logging of all unregistered
        Rails.logger.info("#{self.name}.#{__method__}() Not Registered: #{resource_uri} with opts=#{options}") if Rails.logger.present?
        result = @@ar_strict_mode
      end

      result
    end

    ##
    # Match Any CRUD
    # User Role MUST match CRUD Role AND
    # User options MUST match Resource Options if Resource Options are present
    def self.check_access_permissions? (user_roles, resource_uri, options=nil)
      user_roles = [user_roles] unless user_roles.kind_of?(Array)
      result = false
      value = false
       if is_secured? resource_uri then
         result = catch :found do
           user_roles.each do |user_role|
              CRUD_MODES.each do |crud_mode|
                value  = role_in_resource_crud?(user_role,resource_uri, crud_mode)
                #puts "\tCHECK_ACCESS_PERMISSIONS?(#{user_role}->#{crud_mode}) returned=#{value}"
                next unless value
                opts    = has_options_ary?(user_role,resource_uri,crud_mode)
                value  = role_in_resource_crud_with_option?(user_role,resource_uri,crud_mode,options) if value and opts
                #puts "\t\tCHECK_ACCESS_PERMISSIONS?(#{crud_mode}) returned=#{value}"
                throw :found, true if value
              end # end crud modes
           end # end user roles
           false    # false if nothing  is thrown, i.e not found
         end # end catch
       else
         # TODO: Enable logging of all unregistered
         Rails.logger.info("#{self.name}.#{__method__}() Not Registered: #{resource_uri} with opts=#{options}") if Rails.logger.present?

         result = @@ar_strict_mode
       end

      result
    end

    def self.is_secured?(resource_uri)
      # Must be present and defined as false/un-secured ELSE true, treat it as a secure resource
      !security_check?(resource_uri)
    end

    def self.security_check?(resource_uri)
      # Warden must consider all things true (secured) unless its present and  defined to be different
      return true if (!@@ar_permissions.has_key?(resource_uri) && @@ar_strict_mode)
      (@@ar_permissions.has_key?(resource_uri) && !@@ar_permissions[resource_uri]["secured"]) # prefer the actual value or use the default
    end

    def self.ar_reload_configuration_file
      access_registry = Secure::AccessRegistryUtility.new(Settings.access_profile.access_registry_filename.basename).from_xml()
      content_registry = Secure::AccessRegistryUtility.new(Settings.access_profile.content_registry_filename.basename, 'contentRegistry').from_xml()
      @@ar_permissions = access_registry.merge(content_registry)
      Rails.logger.info("#{self.name}.#{__method__}() Configuration file reloaded!") if Rails.logger.present?
      true
    rescue Exception => e
      @@ar_permissions = access_registry
      Rails.logger.error "#{self.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      false
    end

    ##
    #
    # XML Adaptation of ContentProfile
    # :READ is only permission we support for TopicOptionValues
    ##
    def self.get_resource_content_entries(user_roles, options=nil)
      results = []
      @@ar_permissions.each_pair do |uri, bundle|
        next unless bundle[:content]
        result = get_resource_content_entry(user_roles, uri, options)
        results << result unless result.empty?
      end
      Rails.logger.info("#{self.name}.#{__method__}() opts=#{options}") if Rails.logger.present?
      results
    end
    def self.get_resource_content_entry(user_roles, resource_uri, options=nil)
      bundle = @@ar_permissions[resource_uri]
      results = {}
      if check_access_permissions?(user_roles, resource_uri, options) and bundle.present? and bundle[:content]
        content_type, topic_type, topic_opts = resource_uri.to_s.split('/')

        opts = {}
        user_roles.map do |user_role|
          CRUD_MODES.map do |crud_mode|
            next unless bundle.key?(crud_mode)
            opts.merge!({uri: resource_uri, role: user_role, role_opts: bundle[crud_mode][user_role]}) if has_options_ary?(user_role,resource_uri,crud_mode)
          end
        end

        results = {
            uri: resource_uri.to_s,
            resource_options: opts,
            content_type: content_type,
            content_value: [bundle[:userdata]],
            topic_type: topic_type,
            topic_value: opts.fetch(:role_opts,[]),   # role_opts are now required for use as Topic Options Values -- [topic_opts],
            description: bundle[:description],
            topic_type_description: bundle[:description],
            content_type_description: bundle[:description]
            # Todo: role options are considered Topic Option Values
            # Todo: If user matches multiple CRUDs, then last set of role_option will be used
        }
      else
        results = {}
      end
      Rails.logger.info("#{self.name}.#{__method__}() #{resource_uri} opts=#{options}") if Rails.logger.present?
      results
    end


    protected

    def self.has_options_ary?(role_name, resource_uri, crud_mode="READ")
      !(@@ar_permissions.key?(resource_uri) and
          @@ar_permissions[resource_uri].key?(crud_mode) and
            (@@ar_permissions[resource_uri][crud_mode].key?(role_name) ?
                  @@ar_permissions[resource_uri][crud_mode][role_name].empty? : true))
    end

    def self.role_in_resource_crud?(role_name, resource_uri, crud_mode)
      @@ar_permissions.has_key?(resource_uri) and @@ar_permissions[resource_uri].has_key?(crud_mode) and @@ar_permissions[resource_uri][crud_mode].has_key?(role_name)
    end

    def self.role_in_resource_crud_with_option?(role_name, resource_uri, crud_mode, option)
      option = [option] unless option.kind_of?(Array)
      option.collect {|value| @@ar_permissions[resource_uri][crud_mode][role_name].include?(value) }.any?
    end

  end
end