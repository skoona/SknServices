##
#
# Inherited by: ContentProfileService
#
#

class ProfilesDomain < ::Factory::DomainsBase



  PROFILE_CONTEXT=""  # override in service

  ##
  # Returns a bundle for each available user
  # - includes access/content profile
  def get_page_users(context=PROFILE_CONTEXT)
    usrs = []
    Secure::UserProfile.page_users(context).each do |u|
      usrs << {username: u.username,
               display_name: u.display_name,
               user_options: u.user_options,
               package: [ access_profile_package(u), content_profile_package(u) ]
      }
    end
    usrs
  end

  def manageable_page_users(context=PROFILE_CONTEXT)
    usrs = []
    Secure::UserProfile.page_users(context).each do |u|
      entries = {none: true}

      content_profile = ContentProfile.find_by_person_authentication_key( u.person_authenticated_key)
      unless content_profile.nil? or content_profile.content_profile_entries.empty?

        entries = content_profile.content_profile_entries.map() do |cpe|
          entry = cpe.entry_info
          entry.merge!(content_selects: ContentType.find_by(name: cpe.content_type).options_selects )
          entry.merge!(topic_selects: TopicType.find_by(name: cpe.topic_type).options_selects )
        end
      end
      usrs << {username: u.username,
               display_name: u.display_name,
               email: u.email,
               pak: u.person_authenticated_key,
               authentication_provider: 'SknService::Bcrypt',
               assigned_group: u.assigned_groups,
               user_options: u.user_options,
               profile_exist: !content_profile.nil?,
               profile_entries: entries
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
           accessible_content_url: factory.page_action_paths([:api_accessible_content_profiles_path, {id: 'access', format: :json}]),
           page_user: user_profile.username,
           access_profile: get_page_access_profile(user_profile)
    }
    res[:success] = res[:access_profile][:entries].empty? ? false : true
    unless res[:success]
      res[:message] = res[:access_profile][:message]
    else
      res[:message] = "AccessProfile Entries for #{user_profile.username}:#{user_profile.display_name} Options=#{user_profile.user_options.join(',')}"
    end
    res
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
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
       accessible_content_url: factory.page_action_paths([:api_accessible_content_profiles_path, {id: 'content', format: :json}]),
       page_user: user_profile.username,
       content_profile: get_page_content_profile(user_profile)
    }
    res[:success] = res[:content_profile][:entries].empty? ? false : true
    unless res[:success]
      res[:message] = res[:content_profile][:message]
    else
      res[:message] = "ContentProfile Entry for #{user_profile.username}, #{res[:content_profile][:profile_type]}:#{res[:content_profile][:profile_type_description]}, Options=#{user_profile.user_options.join(',')}"
    end
    res
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
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
  # Parameters: {"id"=>"content",
  #              "username"=>"aptester",
  #              "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
  #              "content_type"=>"Commission", "content_value"=>["68613"],
  #              "topic_type"=>"Branch",
  #              "topic_value"=>["0038"],
  #              "description"=>"Determine which branch documents can be seen",
  #              "topic_type_description"=>"Branch Actions for a specific branch",
  #              "content_type_description"=>"Monthly Commission Reports and Files"
  # }
  # Parameters: {"id"=>"access",
  #              "username"=>"aptester",
  #              "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
  #              "uri"=>"Commission/Branch/PDF",
  #              "resource_options"=>{
  #                  "uri"=>"Commission/Branch/PDF",
  #                  "role"=>"Test.Branch.Commission.Statement.PDF.Access",
  #                  "role_opts"=>["0034", "0037", "0040"]
  #              },
  #              "content_type"=>"Commission",
  #              "content_value"=>{"0"=>{"doctype"=>"954"}},
  #              "topic_type"=>"Branch",
  #              "topic_value"=>["0034", "0037", "0040"],
  #              "description"=>"Branch Commission Statements",
  #              "topic_type_description"=>"Branch Commission Statements",
  #              "content_type_description"=>"Branch Commission Statements"
  # }
  def handle_accessible_content_api(params) # :access, :username, :profile
    @accessible_type = params[:id]          # [:access, :content]
    cpe = params # [:access=role, :content=content]
    pg_u = get_page_user(params[:username], @accessible_type)
      raise(Utility::Errors::NotFound, "No profile data available for user") unless pg_u.present?

    cpe[:profile] = cpe[:id]
    cpe[:id] = pg_u.id
    Rails.logger.debug "#{self.class}##{__method__} results => #{cpe}"

    results = case @accessible_type
                when 'access'
                  {package: {
                      success: true, message: params[:content_type_description], content: 'access',
                      username: pg_u.username, display_name: pg_u.display_name,
                      payload: user_accessible_content(cpe)
                    }
                  }
                when 'content'
                  {package: {
                      success: true, message: params[:content_type_description], content: 'content',
                      username: pg_u.username, display_name: pg_u.display_name,
                      payload: user_accessible_content(cpe)
                    }
                  }
                else
                  {package: {
                      success: false, message: "not found", content: 'error',
                      username: pg_u.username, display_name: pg_u.display_name ,
                      payload: []
                    }
                  }
              end
    SknUtils::PageControls.new(results)
  end

  # Returns an empty Array on Error, or Array of Hashes on Success
  def user_accessible_content(profile)
    result = factory.content_adapter_file_system.available_content_list(profile)
    Rails.logger.debug "#{self.class}##{__method__} results => #{profile}"
    result
  end

  def handle_profiles_management(params)
    {
        success: false,
        message: 'Page Not Implemented!',
        user_package: manageable_page_users,
        page_actions: [{
           id: "test-action",
           path: :manage_content_profiles_profiles_path,
           text: "Refresh",
           icon: 'glyphicon-refresh',
        }],
        package: []
    }
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    {
        success: false,
        message: e.message,
        package: []
    }
  end

  def handle_content_profiles_api(params)
    {
        success: false,
        message: 'Api Not Implemented!',
        package: []
    }
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    {
       success: false,
       message: e.message,
       package: []
    }
  end


  def get_page_user(uname, context=PROFILE_CONTEXT)
    page_user = Secure::UserProfile.page_user(uname, context)
  end

  def get_page_access_profile(user_profile)
    result = factory.profile_builder.access_profile(user_profile)
    result
  end

  def get_page_content_profile(user_profile)
    result = factory.profile_builder.content_profile(user_profile)
    result
  end


end