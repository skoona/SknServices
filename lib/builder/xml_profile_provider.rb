##
# lib/builder/xml_profile_provider.rb
#
# ContentProfile from XML
#
# Storage thru Factory

module Builder
  class XMLProfileProvider < ::Factory::ProvidersBase

    PROVIDER_PREFIX = self.name

    def initialize(params={})
      super(params)
    end

    def self.provider_type
      PROVIDER_PREFIX
    end

    def provider_type
      PROVIDER_PREFIX
    end

    ##
    # Generators of Profile
    ##
    def content_profile_for_user(usr_profile, beaned=false)
      hsh = collect_content_profile_bean(usr_profile)
      beaned ? Utility::ContentProfileBean.new(hsh) : hsh
    end

    # Not ment to be public, it is for testing reason
    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key)
    end

    protected
    ##
    # AccessProfile
    ##
    def collect_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      arobj = get_existing_profile(user_profile)
      return  arobj if arobj

      results = {
          success: true,
          entries: collect_context_profile_entry(user_profile) || [],
          pak: user_profile.person_authenticated_key,
          profile_type: user_profile.assigned_groups.first || "not assigned",
          profile_type_description: user_profile.assigned_groups.first || "not assigned",
          provider: "AccessRegistry",
          username: user_profile.username,
          assigned_group: user_profile.assigned_groups,
          user_options: user_profile.user_options,
          display_name: user_profile.display_name,
          email: user_profile.email
      }
      if results[:entries].empty?
        results = {
            success: false,
            message: "No access profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      unless results[:entries].empty?
        results[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
      end
      update_storage_object(user_profile.person_authenticated_key, results)
      
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
      
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      delete_storage_object(user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end

    def collect_context_profile_entry(usrp)
      Secure::AccessRegistry.get_resource_content_entries(usrp.combined_access_roles, usrp.user_options)
    end

  end
end