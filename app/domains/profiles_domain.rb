##
#
# Inherited by: ContentProfileService, AccessProfileService
#
#

class ProfilesDomain < ::Factory::DomainsBase



  PROFILE_CONTEXT=""  # override in service

  ##
  # Returns a bundle for each available user
  # - includes access/content profile
  def get_page_users(context=PROFILE_CONTEXT)
    usrs = []
    Secure::UserProfile.page_users.each do |u|
      usrs << {username: u.username,
               display_name: u.display_name,
               user_options: u.user_options,
               package: (context.eql?("access") ?
                   access_profile_package(u) :
                   content_profile_package(u) )
      }
    end
    usrs
  end

  ##
  # Builds display package for a single username
  def access_profile_package(user_profile=nil)
    @accessible_type = "access" # [:access, :content]
      raise(Utility::Errors::NotFound, "No profile data available for user") unless user_profile.present?

    res = {
           success: true,
           message: "",
           user_options: user_profile.user_options,
           accessible_content_url: factory.page_action_paths([:accessible_content_profiles_path, {id: 'access', format: :json}]),
           page_user: user_profile.username,
           access_profile: get_page_access_profile(user_profile)
    }
    res[:message] = "AccessProfile Entries for #{user_profile.username}:#{user_profile.display_name} Options=#{user_profile.user_options.join(',')}"
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    {
       success: false,
       user_options: [],
       message: e.message,
       accessible_content_url: nil,
       page_user: "",
       access_profile: []
    }
  end

  ##
  # Builds display package for a single username
  def content_profile_package(user_profile=nil)
    @accessible_type = "content" # [:access, :content]
      raise(Utility::Errors::NotFound, "No profile data available for user") unless user_profile.present?

    res = {
       success: true,
       message: "",
       user_options: user_profile.user_options,
       accessible_content_url: factory.page_action_paths([:accessible_content_profiles_path, {id: 'content', format: :json}]),
       page_user: user_profile.username,
       content_profile: get_page_content_profile(user_profile)
    }
    res[:success] = res[:content_profile][:entries].empty? ? false : true
    unless res[:success]
      res[:message] = res[:content_profile][:message]
    else
      res[:message] = "ContentProfile Entry for #{user_profile.username}, #{res[:content_profile][:profile_type]}:#{res[:content_profile][:profile_type_description]}"
    end
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    {
       success: false,
       message: e.message,
       user_options: [],
       accessible_content_url: nil,
       page_user: "",
       content_profile: []
    }
  end


  ##
  # Returns content available via profile to specified user
  ##
  # REQUEST: { ContentProfile
  #     "user_options":["Manager","0034","0037","0040"],
  #     "topic_value":"Agency",
  #     "content_value":["68601","68602","68603"],
  #     "content_type":"Commission",
  #     "content_type_description":"Monthly Commission Reports and Files",
  #     "topic_type":"Agency",
  #     "topic_type_description":"Agency Actions",
  #     "description":"Determine which agency documents can be seen",
  #     "username":"developer"
  # }
  ##
  # REQUEST:  { AccessProfile
  # "user_options":["Manager","0034","0037","0040"],
  #     "topic_value":"PDF",
  #     "content_value":{"doctype":"954"},
  #     "content_type":"Commission",
  #     "content_type_description":"Agency Commission Statements",
  #     "topic_type":"Agency",
  #     "topic_type_description":"Agency Commission Statements",
  #     "description":"Agency Commission Statements",
  #     "uri":"Commission/Agency/PDF",
  #     "username":"developer"
  # }
  def api_accessible_content(params) # :access, :username, :profile
    @accessible_type = params[:id] || params[:access] # [:access, :content]
    @profile = params[:profile] # [:access=role, :content=content]
    pg_u = get_page_user(params[:username], @accessible_type, false)
      raise(Utility::Errors::NotFound, "No profile data available for user") unless pg_u.present?

    results = case @accessible_type
                when 'access'
                  {package: {success: true, message: params[:content_type_description], content: 'access',
                   username: pg_u.username, display_name: pg_u.display_name ,
                  package: user_accessible_content(pg_u, "access", @profile)}}
                when 'content'
                  {package: {success: true, message: params[:content_type_description], content: 'content',
                   username: pg_u.username, display_name: pg_u.display_name ,
                   package: user_accessible_content(pg_u, "content", @profile)}}
                else
                  {package: {success: false, message: "not found", content: 'error',
                   username: pg_u.username, display_name: pg_u.display_name ,
                   package: []}}
              end
    SknUtils::PageControls.new(results)

  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({package: {
                                 success: false,
                                 message: e.message,
                                 username: "", display_name: "" ,
                                 content: @accessible_type,
                                 package: []
                             }})
  end

  def user_accessible_content(user_profile, context="access", profile=nil)
    [
      {source: "datafiles", filename: "someFile.dat", created: user_profile.last_access, size: "0"},
      {source: "images",    filename: "somePic.png",  created: user_profile.last_access, size: "0"},
      {source: "pdfs",      filename: "someFile.pdf", created: user_profile.last_access, size: "0"}
    ]
  end

  def get_user_form_options
    SknUtils::PageControls.new({
                                   groups: group_select_options,
                                   roles: role_select_options
                               })
  end

  def get_page_user(uname, context=PROFILE_CONTEXT, enable=true)
    @page_user = Secure::UserProfile.page_user(uname, context, enable)
  end

  def get_page_access_profile(user_profile)
    # result = user_profile.access_profile.to_hash   #  access_profile(true)
    #   raise(Utility::Errors::NotFound, "No access profile data available for #{user_profile.display_name}") if result.empty? or result[:entries].empty?
    result = build_ar_content_profile_bean(user_profile)
    # result[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)} if result.key?(:entries)
    result
  end

  def get_page_content_profile(user_profile)
    # result = user_profile.content_profile.to_hash
    result = build_db_content_profile_bean(user_profile)
    # result[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
    result
  end

  def group_select_options
    UserGroupRole.all().map do |r|
      [r.description, r.name]
    end
  end
  def role_select_options
    UserRole.all().map do |r|
      [r.description, r.name]
    end
  end

  def page_user
    @page_user || current_user
  end
  def page_user=(obj)
    @page_user = obj
  end

  ##
  # ContentProfile & AccessProfile

  # Retrieves users content profile in ResultBean
  def build_db_content_profile_bean(user_profile)
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
    factory.remove_existing_object(m_prefix + user_profile.person_authenticated_key)
    results = {
        success: false,
        message: "No content profile data available for #{user_profile.display_name}",
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

  def build_ar_content_profile_bean(user_profile)
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
    factory.remove_existing_object(m_prefix + user_profile.person_authenticated_key)
    results = {
        success: false,
        message: "No content profile data available for #{user_profile.display_name}",
        entries:[]
    }
  end
  def build_ar_context_profile_entry(usrp)
    get_resource_content_entries(usrp.roles, usrp.user_options)
  end
  def get_resource_content_entries(user_roles, options=nil)
    results = []
    Secure::AccessRegistry.get_ar_permissions_hash.each_pair do |uri, bundle|
      next unless bundle[:content]
      result = get_resource_content_entry(user_roles, uri, options)
      results << result unless result.empty?
    end
    Rails.logger.info("#{self.class.name}.#{__method__}() opts=#{options}, #{results}") if Rails.logger.present?
    results
  end
  def get_resource_content_entry(user_roles, resource_uri, options=nil)
    bundle = Secure::AccessRegistry.get_ar_permissions_hash[resource_uri]
    results = {}
    if Secure::AccessRegistry.check_access_permissions?(user_roles, resource_uri, options) and bundle.present? and bundle[:content]
      content_type, topic_type, topic_opts = resource_uri.to_s.split('/')

      opts = {}
      user_roles.map do |user_role|
        Secure::AccessRegistry.get_crud_modes.map do |crud_mode|
          next unless bundle.key?(crud_mode)
          opts.merge!({uri: resource_uri, role: user_role, role_opts: bundle[crud_mode][user_role]}) if Secure::AccessRegistry.has_options_ary?(user_role,resource_uri,crud_mode)
        end
      end

      results = {
          uri: resource_uri.to_s,
          resource_options: opts,
          content_type: content_type,
          content_value: bundle[:userdata],
          topic_type: topic_type,
          topic_value: topic_opts,
          description: bundle[:description],
          topic_type_description: bundle[:description],
          content_type_description: bundle[:description]
          # Todo: role options may be needed too, content_profile_entry#entry_info
      }
    else
      results = {}
    end
    Rails.logger.info("#{self.class.name}.#{__method__}() #{resource_uri} opts=#{options}, #{results} ++ bundle=#{bundle}") if Rails.logger.present?
    results
  end


end