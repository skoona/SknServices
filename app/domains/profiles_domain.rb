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

    res = SknUtils::PageControls.new({
                                   success: true,
                                   message: "",
                                   user_options: user_profile.user_options,
                                   accessible_content_url: factory.controller.page_action_paths([:accessible_content_profiles_path, {id: 'access', format: :json}]),
                                   page_user: user_profile.username,
                                   access_profile: get_page_access_profile(user_profile)
                               })
    res.message = "AccessProfile Entries for #{user_profile.username}:#{user_profile.display_name} Options=#{user_profile.user_options.join(',')}"
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                   success: false,
                                   user_options: [],
                                   message: e.message,
                                   accessible_content_url: nil,
                                   page_user: "",
                                   access_profile: []
                               })
  end

  ##
  # Builds display package for a single username
  def content_profile_package(user_profile=nil)
    @accessible_type = "content" # [:access, :content]
      raise(Utility::Errors::NotFound, "No profile data available for user") unless user_profile.present?

    res = SknUtils::PageControls.new({
                                   success: true,
                                   message: "",
                                   user_options: user_profile.user_options,
                                   accessible_content_url: factory.controller.page_action_paths([:accessible_content_profiles_path, {id: 'content', format: :json}]),
                                   page_user: user_profile.username,
                                   content_profile: get_page_content_profile(user_profile)
                               })
    res.message = "ContentProfile Entry for #{user_profile.username}, #{res.content_profile.profile_type}:#{res.content_profile.profile_type_description}"
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                 success: false,
                                 message: e.message,
                                 user_options: [],
                                 accessible_content_url: nil,
                                 page_user: "",
                                 content_profile: []
                             })
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
    result = user_profile.access_profile.to_hash   #  access_profile(true)
      raise(Utility::Errors::NotFound, "No access profile data available for #{user_profile.display_name}") if result.empty? or result[:entries].empty?
    result[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)} if result.key?(:entries)
    result
  end

  def get_page_content_profile(user_profile)
    result = user_profile.content_profile.to_hash
      raise(Utility::Errors::NotFound, "No content profile data available for #{user_profile.display_name}") if result.nil? or result.empty? or result[:entries].empty?
    result[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)} if result.key?(:entries)
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

end