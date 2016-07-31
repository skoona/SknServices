##
# lib/builder/db_profile_provider.rb
#
# ContentProfile from DB
#
# Storage thru Factory

module Builder
  class DBProfileProvider < ::Factory::DomainsBase

    PROVIDER_PREFIX = self.name

    def initialize(params={})
      super(params)
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

    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key, PROVIDER_PREFIX)
    end

  protected
    ##
    # ContentProfile
    ##

    # Retrieves users content profile in ResultBean
    def collect_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      cpobj = get_existing_profile(user_profile)
      return  cpobj if cpobj

      results = {}
      ctxp = ContentProfile.find_by( person_authentication_key: user_profile.person_authenticated_key)

      unless ctxp.nil?
        results =  ctxp.entry_info_with_selects(user_profile).merge({ success: true })
      else
        results = {
            success: false,
            message: "No content profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      factory.update_storage_object(PROVIDER_PREFIX + user_profile.person_authenticated_key, results)

      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
      
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      factory.delete_storage_object(PROVIDER_PREFIX + user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end

  end
end