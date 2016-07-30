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
               user_options: u.user_options || [],
               package: [ access_profile_package(u), content_profile_package(u) ]
      }
    end
    usrs
  end

  # Returns:
  # [
  #  {:pak=>"6df717145082c39fc52027947411b66d",
  #   :profile_type=>"Developer",
  #   :profile_type_description=>"Open Source Independent Consultancy",
  #   :provider=>"SknService::Bcrypt",
  #   :username=>"developer",
  #   :display_name=>"Skoona Developer",
  #   :email=>"skoona@gmail.com",
  #   :assigned_group=>["Developer", "EmployeePrimary"],
  #   :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"],
  #   :entries=>[
  #       { :content_value=>["*.log", "*.csv", "*.pdf"],
  #         :content_type=>"Commission",
  #         :content_type_description=>"Branch Actions for a specific branch",
  #         :topic_value=>["0040", "0037", "0034"],
  #         :topic_type=>"Branch",
  #         :topic_type_description=>"Branch Actions for a specific branch",
  #         :description=>"Determine which branch documents can be seen",
  #         :content_selects=>[["Commission", 1, {:"data-description"=>"Monthly Commission Reports and Files"}],
  #                            ["Commission", 4, {:"data-description"=>"Monthly Commission Reports and Files"}]
  #                           ],
  #         :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}],
  #                          ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}],
  #                          ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}],
  #                          ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}],
  #                          ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]
  #                         ]
  #       },
  #       {:content_value=>["Cancel", "FutCancel", "AdvCancel"], :content_type=>"Notification", :content_type_description=>"Account Actions for a specific branch", :topic_value=>["1602", "1601"], :topic_type=>"Branch", :topic_type_description=>"Account Actions for a specific branch", :description=>"Determine which branch accounts will have notification sent", :content_selects=>[["Notification", 2, {:"data-description"=>"Email Notification of Related Events"}], ["Notification", 5, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]},
  #       {:content_value=>["23", "9", "21"], :content_type=>"LicensedStates", :content_type_description=>"Branch Operations for a specific branch", :topic_value=>["0040", "0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Operations for a specific branch", :description=>"Determine which States branches are authorized to operate in.", :content_selects=>[["LicensedStates", 3, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}
  #   ],
  #   :profile_exist=>true
  #  },
  #  {:pak=>"fd53d41a6985eaac881b0f6ad4fbdc2f", :profile_type=>nil, :profile_type_description=>nil, :provider=>"SknService::Bcrypt", :username=>"eptester", :display_name=>"Employee Primary User", :email=>"appdev@localhost.com", :assigned_group=>["Manager", "EmployeePrimary"], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :entries=>[{:content_value=>["*.log", "*.csv", "*.pdf"], :content_type=>"Commission", :content_type_description=>"Branch Actions for a specific branch", :topic_value=>["0040", "0037", "0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Determine which branch documents can be seen", :content_selects=>[["Commission", 1, {:"data-description"=>"Monthly Commission Reports and Files"}], ["Commission", 4, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}, {:content_value=>["Cancel", "FutCancel", "AdvCancel"], :content_type=>"Notification", :content_type_description=>"Account Actions for a specific branch", :topic_value=>["1602", "1601"], :topic_type=>"Branch", :topic_type_description=>"Account Actions for a specific branch", :description=>"Determine which branch accounts will have notification sent", :content_selects=>[["Notification", 2, {:"data-description"=>"Email Notification of Related Events"}], ["Notification", 5, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}, {:content_value=>["23", "9", "21"], :content_type=>"LicensedStates", :content_type_description=>"Branch Operations for a specific branch", :topic_value=>["0040", "0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Operations for a specific branch", :description=>"Determine which States branches are authorized to operate in.", :content_selects=>[["LicensedStates", 3, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}], :profile_exist=>true},
  #  {:pak=>"0a83f6375675cb436beaec50387826d2", :profile_type=>"EmployeeSecondary", :profile_type_description=>"Corporate Staff", :provider=>"SknService::Bcrypt", :username=>"estester", :display_name=>"Employee Secondary User", :email=>"appdev1@localhost.com", :assigned_group=>["EmployeeSecondary"], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Commission", :content_type_description=>"Branch Actions for a specific branch", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Determine which branch documents can be seen", :content_selects=>[["Commission", 1, {:"data-description"=>"Monthly Commission Reports and Files"}], ["Commission", 4, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}, {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Account Actions for a specific branch", :topic_value=>["1602"], :topic_type=>"Branch", :topic_type_description=>"Account Actions for a specific branch", :description=>"Determine which branch accounts will have notification sent", :content_selects=>[["Notification", 2, {:"data-description"=>"Email Notification of Related Events"}], ["Notification", 5, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}], :profile_exist=>true},
  #  {:pak=>"57c730e983e8ba70c79b88c153f3db87", :profile_type=>"BranchPrimary", :profile_type_description=>"Branch Manager", :provider=>"SknService::Bcrypt", :username=>"bptester", :display_name=>"Branch Primary User", :email=>"appdev2@localhost.com", :assigned_group=>["BranchPrimary"], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Commission", :content_type_description=>"Branch Actions for a specific branch", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Determine which branch documents can be seen", :content_selects=>[["Commission", 1, {:"data-description"=>"Monthly Commission Reports and Files"}], ["Commission", 4, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}, {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Account Actions for a specific branch", :topic_value=>["1602"], :topic_type=>"Branch", :topic_type_description=>"Account Actions for a specific branch", :description=>"Determine which branch accounts will have notification sent", :content_selects=>[["Notification", 2, {:"data-description"=>"Email Notification of Related Events"}], ["Notification", 5, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 2, {:"data-description"=>"Account Actions for a specific branch"}], ["Branch", 3, {:"data-description"=>"Branch Operations for a specific branch"}], ["Branch", 4, {:"data-description"=>"Branch Actions for a specific branch"}], ["Branch", 5, {:"data-description"=>"Account Actions for a specific branch"}]]}], :profile_exist=>true},
  #  {:pak=>"e3e2d2825c89586a62092473cbd7e4bb", :profile_type=>"BranchSecondary", :profile_type_description=>"Branch Staff", :provider=>"SknService::Bcrypt", :username=>"bstester", :display_name=>"Branch Secondary User", :email=>"appdev3@localhost.com", :assigned_group=>["BranchSecondary"], :user_options=>["BranchSecondary", "0037", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"This Corporate Account", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Relationship Activity Reports", :content_selects=>[["Activity", 6, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["Partner", 6, {:"data-description"=>"This Corporate Account"}]]}], :profile_exist=>true}, {:profile_exist=>false},
  #  {:pak=>"54239b66782502bab08259e8dadb0b8c", :profile_type=>"VendorPrimary", :profile_type_description=>"Partner Manager", :provider=>"SknService::Bcrypt", :username=>"vptester", :display_name=>"Vendor Primary User", :email=>"appdev4@localhost.com", :assigned_group=>["VendorPrimary"], :user_options=>["VendorPrimary", "0099"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"This Corporate Account", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Relationship Activity Reports", :content_selects=>[["Activity", 6, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["Partner", 6, {:"data-description"=>"This Corporate Account"}]]}], :profile_exist=>true}, {:profile_exist=>false}
  # ]

  def manageable_page_users(context=PROFILE_CONTEXT)
    usrs = []

    Secure::UserProfile.page_users(context).each do |u|
      entries = {none: true}
      profile = {}

      content_profile = ContentProfile.find_by_person_authentication_key( u.person_authenticated_key)

      unless content_profile.nil?
        profile = content_profile.entry_info_with_selects(u)
      else
        profile = {
            username: u.username,
            display_name: u.display_name,
            email: u.email,
            pak: u.person_authenticated_key,
            authentication_provider: 'SknService::Bcrypt',
            assigned_group: u.assigned_groups,
            user_options: u.user_options,
            profile_type_description: "",
            entries: []
        }
      end
      usrs <<  profile.merge(profile_exist: !content_profile.nil?)
    end
    Rails.logger.warn "#{self.class.name}.#{__method__}() returns: #{usrs}"

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
           user_options: (user_profile.user_options || []),
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
       user_options: (user_profile.user_options || []),
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
  #              "content_type"=>"Commission",
  #              "content_value"=>["68613"],
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
    result = adapter_for_content_profile_entry(profile).available_content_list(profile)
    Rails.logger.debug "#{self.class}##{__method__} results => #{result}"
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
    result = profile_provider.access_profile(user_profile)
    result
  end

  def get_page_content_profile(user_profile)
    result = profile_provider.content_profile(user_profile)
    result
  end


end