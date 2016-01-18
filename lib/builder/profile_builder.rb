##
# lib/builder/profile_builder.rb
#
# ContentProfile & AccessProfile Builder
#
# Storage thru Factory

module Builder
  class ProfileBuilder < ::Factory::DomainsBase

    def initialize(params={})
      super(params)
    end

    def combined_profiles(usr_profile, beaned=false)
      c_hsh = content_profile(usr_profile, beaned)
      a_hsh = access_profile(usr_profile, beaned)
      [a_hsh, c_hsh]
    end
    def content_profile(usr_profile, beaned=false)
      hsh = build_db_content_profile_bean(usr_profile)
      beaned ? Utility::ContentProfileBean.new(hsh) : hsh
    end
    def access_profile(usr_profile, beaned=false)
      hsh = build_ar_content_profile_bean(usr_profile)
      beaned ? Utility::ContentProfileBean.new(hsh) : hsh
    end

  protected
    ##
    # ContentProfile
    ##

    # Retrieves users content profile in ResultBean
    def build_db_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      m_prefix = 'content'
      return  factory.get_existing_object(m_prefix + user_profile.person_authenticated_key) if factory.existing_object_stored?(m_prefix + user_profile.person_authenticated_key)
      results = {}
      ctxp = ContentProfile.find_by_person_authentication_key(user_profile.person_authenticated_key)
      unless ctxp.nil? or ctxp.content_profile_entries.size == 0
        results =  {
            entries: (ctxp.content_profile_entries.map() {|cpe| build_db_context_profile_entry(cpe)}) || [],
            pak: ctxp.person_authentication_key,
            profile_type: ctxp.profile_type.name,
            profile_type_description: ctxp.profile_type.description,
            provider: ctxp.authentication_provider,
            username: ctxp.username,
            display_name: ctxp.display_name,
            email: ctxp.email
        }
      end
      if  results.empty? or !results[:entries].present?
        results = {
            success: false,
            message: "No content profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      unless results[:entries].empty?
        results[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
      end
      factory.set_existing_object(m_prefix + user_profile.person_authenticated_key, results)
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      factory.remove_existing_object(m_prefix + user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end
    def build_db_context_profile_entry(cpe)
      ctv = cpe.content_types.map {|r| r.content_type_opts.map(&:value) }.flatten
      ttv = cpe.topic_types.map {|r| r.topic_type_opts.map(&:value) }.flatten
      {
          content_value: ctv,
          content_type: cpe.content_type_name,
          content_type_description: cpe.content_types.first.try(:description) || "not assigned",
          topic_value: ttv,
          topic_type: cpe.topic_type_name,
          topic_type_description: cpe.topic_types.first.try(:description) || "not assigned",
          description: cpe.description
      }
    end

    ##
    # AccessProfile
    ##
    def build_ar_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      m_prefix = 'access'
      return  factory.get_existing_object(m_prefix + user_profile.person_authenticated_key) if factory.existing_object_stored?(m_prefix + user_profile.person_authenticated_key)
      results = {
          entries: build_ar_context_profile_entry(user_profile) || [],
          pak: user_profile.person_authenticated_key,
          profile_type: user_profile.assigned_groups.first || "not assigned",
          profile_type_description: "",
          provider: "UserProfile",
          username: user_profile.username,
          display_name: user_profile.display_name,
          email: user_profile.email
      }
      if results[:entries].empty?
        results = {
            success: false,
            message: "No content profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      unless results[:entries].empty?
        results[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
      end
      factory.set_existing_object(m_prefix + user_profile.person_authenticated_key, results)
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      factory.remove_existing_object(m_prefix + user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end
    def build_ar_context_profile_entry(usrp)
      Secure::AccessRegistry.get_resource_content_entries(usrp.roles, usrp.user_options)
    end

  end
end