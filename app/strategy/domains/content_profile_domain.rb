##
# # File: <root>/app/strategy/domains/content_profile_domain.rb
#
# Inherited by: ContentService
#
#
module Domains

  class ContentProfileDomain < DomainsBase


    PROFILE_CONTEXT=""  # override in service

    def runtime_demo_package
      profile = db_profile_provider.content_profile_for_runtime(current_user)
      success = profile.present? && profile[:display_groups].present?
      {
        message: (success ? "" : "No Access Provided.  Please contact Customer Service with any questions."),
        cp: (success ? profile : {}),
        display_groups: (success ? profile.delete(:display_groups) : []),
        get_demo_content_object_url: page_action_paths([:api_get_demo_content_object_profiles_path])
      }
    end

    ##
    # Returns a bundle for each available user
    # - includes access/content profile
    def get_page_users(context=PROFILE_CONTEXT)
      usrs = []
      Secure::UserProfile.page_users(context).each do |u|
        usrs << {username: u.username,
                 display_name: u.display_name,
                 user_options: u.user_options || [],
                 get_content_object_url: page_action_paths([:api_get_content_object_profiles_path]),
                 package: [ access_profile_package(u), content_profile_package(u) ]
        }
      end
      usrs
    end

    def get_page_user(uname, context=PROFILE_CONTEXT)
      page_user = Secure::UserProfile.page_user(uname, context)
    end

    # Username,        Commission, Experience, Notification, LicensedStates, Activity,   FileDownloads
    #  #display_name   True/False  True/False  True/False    True/False      True/False  True/False
    def members_admin_package
      package = {display_groups: ["Under Construction"]}
      success = true
      {
          success: success,
          message: (success ? "" : "No Groups Available.  Please contact Customer Service with any questions."),
          display_groups: (success ? package.delete(:display_groups) : [])
      }
    end

    # UserInfo
    #    * Branch 0034, Commission, Experience, Notification, LicensedStates        -- ADD Branch Section needed, + Licensed States is MultiSelect
    #    - Branch 0037, Commission, Experience, Notification, LicensedStates
    #    - Branch 0040, Commission, Experience, Notification, LicensedStates
    #    * Partner 0099, Activity
    #    * UserGroups:FileDownloads, [ Employee Primary, Employee Secondary, Branch Primary, Branch Secondary, Vendor Primary, Vendor Secondary ]

    def member_admin_package(params) # username
      up = get_page_user(params['username'])
      profile = db_profile_provider.content_profile_for_runtime(up, false)

      partners = []
      SknSettings.Related.partners.to_h.each_pair {|k,v| partners << ["#{k} | #{v}", k] }
      branches = []
      SknSettings.Related.branches.to_h.each_pair {|k,v| branches << ["#{k} | #{v}", k] }

      package = {
           profile: profile,
           states: db_profile_provider.long_state_name_options,
           user_groups: SknSettings.Related.user_groups,
           partners: partners,
           branches: branches
      }

      success = profile.present?
      {
          success: success,
          message: (success ? "" : "No Information available for #{params['username']}.  Please contact Customer Service with any questions."),
          display_groups: (success ? package : {})
      }
    end

    # Returns:
    # [
    #   {:pak=>"5f7d8a3fdfff5961deefac65851b77c6",
    #    :profile_type=>"Developer",
    #    :profile_type_description=>"Open Source Independent Consultancy",
    #    :provider=>"SknService::Bcrypt",
    #    :username=>"developer",
    #    :display_name=>"Skoona Developer",
    #    :email=>"skoona@gmail.com",
    #    :assigned_group=>["Developer", "EmployeePrimary"],
    #    :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"],
    #    :entries=>[
    #      {:content_value=>["*.pdf"],
    #       :content_type=>"Commission",
    #       :content_type_description=>"Monthly Commission Reports and Files",
    #       :topic_value=>["0034"],
    #       :topic_type=>"Branch",
    #       :topic_type_description=>"Branch Actions for a specific branch",
    #       :description=>"Access Branch Commission PDF Files",
    #       :content_selects=>[["*.pdf", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]],
    #       :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]],
    #       :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"],
    #       :username=>"developer"
    #      },
    #      {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["AdvCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["21"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["21", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["*.csv"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission CSV Files", :content_selects=>[["*.csv", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["Cancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["Cancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["23"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["23", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["*.log"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission LOG Files", :content_selects=>[["*.log", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["FutCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["FutCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"},
    #      {:content_value=>["*.pdf", "*.jpg", "*.png"], :content_type=>"FileDownload", :content_type_description=>"Project Related Images", :topic_value=>["Developer", "EmployeePrimary", "Manager"], :topic_type=>"UserGroups", :topic_type_description=>"Shared access to project working files", :description=>"Shared access to project working files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Related Images"}], ["*.jpg", 0, {:"data-description"=>"Project Related Images"}], ["*.png", 0, {:"data-description"=>"Project Related Images"}]], :topic_selects=>[["Developer", 0, {:"data-description"=>"Shared access to project working files"}], ["EmployeePrimary", 0, {:"data-description"=>"Shared access to project working files"}], ["Manager", 0, {:"data-description"=>"Shared access to project working files"}]], :user_options=>["Developer", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "USA"], :username=>"developer"}
    #    ],
    #    :success=>true,
    #    :profile_exist=>true
    #   },
    #
    #   {:pak=>"872ec0538fa33a8f31995bf813864334", :profile_type=>"Manager", :profile_type_description=>"Corporate Managers", :provider=>"SknService::Bcrypt", :username=>"eptester", :display_name=>"Employee Primary User", :email=>"appdev@localhost.com", :assigned_group=>["Manager", "EmployeePrimary"], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission PDF Files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["AdvCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["21"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["21", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["*.csv"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission CSV Files", :content_selects=>[["*.csv", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["Cancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["Cancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["23"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0037"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["23", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0037", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["*.log"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission LOG Files", :content_selects=>[["*.log", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["FutCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["FutCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}, {:content_value=>["*.pdf", "*.jpg", "*.png"], :content_type=>"FileDownload", :content_type_description=>"Project Related Images", :topic_value=>["Developer", "EmployeePrimary", "Manager"], :topic_type=>"UserGroups", :topic_type_description=>"Shared access to project working files", :description=>"Shared access to project working files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Related Images"}], ["*.jpg", 0, {:"data-description"=>"Project Related Images"}], ["*.png", 0, {:"data-description"=>"Project Related Images"}]], :topic_selects=>[["Developer", 0, {:"data-description"=>"Shared access to project working files"}], ["EmployeePrimary", 0, {:"data-description"=>"Shared access to project working files"}], ["Manager", 0, {:"data-description"=>"Shared access to project working files"}]], :user_options=>["Manager", "EmployeePrimary", "0034", "0037", "0040", "0099", "1601", "1602", "USA"], :username=>"eptester"}], :success=>true, :profile_exist=>true},
    #   {:pak=>"6d882142dd0011f6058facdbaa6e5624", :profile_type=>"EmployeeSecondary", :profile_type_description=>"Corporate Staff", :provider=>"SknService::Bcrypt", :username=>"estester", :display_name=>"Employee Secondary User", :email=>"appdev1@localhost.com", :assigned_group=>["EmployeeSecondary"], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission PDF Files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}, {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["AdvCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}, {:content_value=>["21"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["21", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}, {:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}, {:content_value=>["*.log"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission LOG Files", :content_selects=>[["*.log", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}, {:content_value=>["FutCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["FutCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["EmployeeSecondary", "0037", "0099", "1602", "USA"], :username=>"estester"}], :success=>true, :profile_exist=>true},
    #   {:pak=>"7c29758d7134bad832c5c0277bb61263", :profile_type=>"BranchPrimary", :profile_type_description=>"Branch Manager", :provider=>"SknService::Bcrypt", :username=>"bptester", :display_name=>"Branch Primary User", :email=>"appdev2@localhost.com", :assigned_group=>["BranchPrimary"], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission PDF Files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}, {:content_value=>["AdvCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["AdvCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}, {:content_value=>["21"], :content_type=>"LicensedStates", :content_type_description=>"Business Operational Metric", :topic_value=>["0034"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Licensed to operate in state", :content_selects=>[["21", 0, {:"data-description"=>"Business Operational Metric"}]], :topic_selects=>[["0034", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}, {:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}, {:content_value=>["*.log"], :content_type=>"Commission", :content_type_description=>"Monthly Commission Reports and Files", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Access Branch Commission LOG Files", :content_selects=>[["*.log", 0, {:"data-description"=>"Monthly Commission Reports and Files"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}, {:content_value=>["FutCancel"], :content_type=>"Notification", :content_type_description=>"Email Notification of Related Events", :topic_value=>["0040"], :topic_type=>"Branch", :topic_type_description=>"Branch Actions for a specific branch", :description=>"Notify Branch of Policy Events", :content_selects=>[["FutCancel", 0, {:"data-description"=>"Email Notification of Related Events"}]], :topic_selects=>[["0040", 0, {:"data-description"=>"Branch Actions for a specific branch"}]], :user_options=>["BranchPrimary", "0034", "0037", "0040", "USA"], :username=>"bptester"}], :success=>true, :profile_exist=>true},
    #   {:pak=>"4d353db63899aee32988677c89602d98", :profile_type=>"BranchSecondary", :profile_type_description=>"Branch Staff", :provider=>"SknService::Bcrypt", :username=>"bstester", :display_name=>"Branch Secondary User", :email=>"appdev3@localhost.com", :assigned_group=>["BranchSecondary"], :user_options=>["BranchSecondary", "0037", "USA"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["BranchSecondary", "0037", "USA"], :username=>"bstester"}, {:content_value=>["*.pdf"], :content_type=>"FileDownload", :content_type_description=>"Project Related Images", :topic_value=>["VendorPrimary"], :topic_type=>"UserGroups", :topic_type_description=>"Shared access to project working files", :description=>"Shared access to project working files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Related Images"}]], :topic_selects=>[["VendorPrimary", 0, {:"data-description"=>"Shared access to project working files"}]], :user_options=>["BranchSecondary", "0037", "USA"], :username=>"bstester"}], :success=>true, :profile_exist=>true},
    #   {:success=>false, :username=>"bnptester", :display_name=>"Branch No Privileges User", :email=>"appdev6@localhost.com", :pak=>"6bb71298617a319a03ba85553fa461d6", :authentication_provider=>"SknService::Bcrypt", :assigned_group=>["BranchSecondary"], :user_options=>[], :profile_type_description=>"", :entries=>[], :profile_exist=>false},
    #   {:pak=>"0c3d2ff173f9600f2b7efb07bfada939", :profile_type=>"VendorPrimary", :profile_type_description=>"Partner Manager", :provider=>"SknService::Bcrypt", :username=>"vptester", :display_name=>"Vendor Primary User", :email=>"appdev4@localhost.com", :assigned_group=>["VendorPrimary"], :user_options=>["VendorPrimary", "0099"], :entries=>[{:content_value=>["*.pdf"], :content_type=>"Activity", :content_type_description=>"Project Status Reports", :topic_value=>["0099"], :topic_type=>"Partner", :topic_type_description=>"This Corporate Account", :description=>"Access Relationship Documents", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]], :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]], :user_options=>["VendorPrimary", "0099"], :username=>"vptester"}, {:content_value=>["*.pdf"], :content_type=>"FileDownload", :content_type_description=>"Project Related Images", :topic_value=>["VendorPrimary"], :topic_type=>"UserGroups", :topic_type_description=>"Shared access to project working files", :description=>"Shared access to project working files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Related Images"}]], :topic_selects=>[["VendorPrimary", 0, {:"data-description"=>"Shared access to project working files"}]], :user_options=>["VendorPrimary", "0099"], :username=>"vptester"}], :success=>true, :profile_exist=>true},
    #   {:success=>false, :username=>"vstester", :display_name=>"Vendor Secondary User", :email=>"appdev5@localhost.com", :pak=>"2061b7eba6e6b3419e89c6b9b293ff9a", :authentication_provider=>"SknService::Bcrypt", :assigned_group=>["VendorSecondary"], :user_options=>["VendorSecondary", "0099"], :profile_type_description=>"", :entries=>[], :profile_exist=>false}
    # ]

    def management_page_users_package(context=PROFILE_CONTEXT)
      usrs = []

      Secure::UserProfile.page_users(context).each do |u|

        content_profile = nil

        content_profile = db_profile_provider.content_profile_for_user(u)

        unless content_profile and content_profile[:success]
          content_profile = {
              success: false,
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

        usrs <<  content_profile.merge(profile_exist: content_profile[:success])
      end
      results = {
        profile_type_options: ProfileType.option_selects.map() {|s| [s[0] = "#{s[0]} : #{s[2][:data][:description]}", s[1]]},
        content_type_options: ContentType.option_selects.map() {|s| [s[0] = "#{s[0]} : #{s[2][:data][:description]}", s[1], s[2]]},
        content_type_opts_options: ContentTypeOpt.option_selects('Commission').map() {|s| [s[0] = "#{s[0]} : #{s[2][:data][:description]}", s[1]]},
        topic_type_options: TopicType.option_selects.map() {|s| [s[0] = "#{s[0]} : #{s[2][:data][:description]}", s[1], s[2]]},
        topic_type_opts_options: TopicTypeOpt.option_selects('Branch').map() {|s| [s[0] = "#{s[0]} : #{s[2][:data][:description]}", s[1]]},
        package: usrs
      }
      Rails.logger.debug "#{self.class.name}.#{__method__}() returns: #{results[:package].present?}"

      results
    end


    ##
    # Builds display package for a single username
    # Returns:
    # {
    #   :success=>false,
    #   :message=>"No access profile data available for Branch No Privileges User",
    #   :user_options=>[],
    #   :accessible_content_url=>"/profiles/api_accessible_content.json?id=access",
    #   :page_user=>"bnptester",
    #   :access_profile=>{
    #     :success=>false,
    #     :message=>"No access profile data available for Branch No Privileges User",
    #     :username=>"bnptester",
    #     :entries=>[]
    #   }
    # }
    #
    # -- OR --
    #
    # {
    #   :success=>true,
    #   :message=>"AccessProfile Entries for vptester:Vendor Primary User Options=VendorPrimary,0099",
    #   :user_options=>["VendorPrimary", "0099"],
    #   :accessible_content_url=>"/profiles/api_accessible_content.json?id=access",
    #   :page_user=>"vptester",
    #   :access_profile=>{:
    #     :success=>true,
    #     :pak=>"0c3d2ff173f9600f2b7efb07bfada939",
    #     :profile_type=>"VendorPrimary",
    #     :profile_type_description=>"VendorPrimary",
    #     :provider=>"AccessRegistry",
    #     :username=>"vptester",
    #     :assigned_group=>["VendorPrimary"],
    #     :user_options=>["VendorPrimary", "0099"],
    #     :display_name=>"Vendor Primary User",
    #     :email=>"appdev4@localhost.com",
    #     :entries=>[
    #       { :uri=>"Activity/Partner/0099",
    #         :resource_options=>{
    #           :uri=>"Activity/Partner/0099",
    #           :role=>"Services.Action.Use.FileDownload.Pdf",
    #           :role_opts=>["0099"]
    #         },
    #         :content_type=>"Activity",
    #         :content_value=>["*.pdf"],
    #         :topic_type=>"Partner",
    #         :topic_value=>["0099"],
    #         :description=>"Partner Relationship Reports",
    #         :topic_type_description=>"Partner Relationship Reports",
    #         :content_type_description=>"Partner Relationship Reports",
    #         :username=>"vptester",
    #         :user_options=>["VendorPrimary", "0099"]
    #       }
    #     ]
    #   }
    # }
    #
    # {:success=>true, :message=>"AccessProfile Entries for vptester:Vendor Primary User Options=VendorPrimary,0099", :user_options=>["VendorPrimary", "0099"], :accessible_content_url=>"/profiles/api_accessible_content.json?id=access", :page_user=>"vptester", :access_profile=>{:success=>true, :entries=>[{:uri=>"Activity/Partner/0099", :resource_options=>[{:uri=>"Activity/Partner/0099", :role=>"Services.Action.Use.FileDownload.Pdf", :role_opts=>["0099"]}], :content_type=>"Activity", :content_value=>["*.pdf"], :topic_type=>"Partner", :topic_value=>["0099"], :description=>"Partner Relationship Reports", :topic_type_description=>"Partner Relationship Reports", :content_type_description=>"Partner Relationship Reports", :username=>"vptester", :user_options=>["VendorPrimary", "0099"]}, {:uri=>"FileDownload/UserGroups/Pdf", :resource_options=>[{:uri=>"FileDownload/UserGroups/Pdf", :role=>"Services.Action.Use.FileDownload.Pdf", :role_opts=>["VendorSecondary", "VendorPrimary", "EmployeeSecondary", "EmployeePrimary"]}], :content_type=>"FileDownload", :content_value=>["*.pdf"], :topic_type=>"UserGroups", :topic_value=>["VendorPrimary"], :description=>"Permission to Download PDF Files", :topic_type_description=>"Permission to Download PDF Files", :content_type_description=>"Permission to Download PDF Files", :username=>"vptester", :user_options=>["VendorPrimary", "0099"]}, {:uri=>"FileDownload/UserGroups/Datafiles", :resource_options=>[{:uri=>"FileDownload/UserGroups/Datafiles", :role=>"Services.Action.Use.FileDownload.Datafile", :role_opts=>["VendorSecondary", "VendorPrimary", "EmployeeSecondary", "EmployeePrimary"]}], :content_type=>"FileDownload", :content_value=>["*.log"], :topic_type=>"UserGroups", :topic_value=>["VendorPrimary"], :description=>"Permission to Download Data Files", :topic_type_description=>"Permission to Download Data Files", :content_type_description=>"Permission to Download Data Files", :username=>"vptester", :user_options=>["VendorPrimary", "0099"]}, {:uri=>"FileDownload/UserGroups/Images", :resource_options=>[{:uri=>"FileDownload/UserGroups/Images", :role=>"Services.Action.Use.FileDownload.Image", :role_opts=>["VendorSecondary", "VendorPrimary", "EmployeeSecondary", "EmployeePrimary"]}], :content_type=>"FileDownload", :content_value=>["*.png", "*.jpg"], :topic_type=>"UserGroups", :topic_value=>["VendorPrimary"], :description=>"Permission to Download Image Files", :topic_type_description=>"Permission to Download Image Files", :content_type_description=>"Permission to Download Image Files", :username=>"vptester", :user_options=>["VendorPrimary", "0099"]}], :pak=>"63001ba01dfe8c5f888fd579c6a4cfdc", :profile_type=>"VendorPrimary", :profile_type_description=>"VendorPrimary", :provider=>"Secure::AccessRegistry", :username=>"vptester", :assigned_group=>["VendorPrimary"], :user_options=>["VendorPrimary", "0099"], :display_name=>"Vendor Primary User", :email=>"appdev4@localhost.com"}}
    def access_profile_package(user_profile=nil)
      @accessible_type = "access" # [:access, :content]
        raise(Utility::Errors::NotFound, "No profile data available for user") unless user_profile.present?

      res = {
             success: true,
             message: "",
             user_options: (user_profile.user_options || []),
             accessible_content_url: page_action_paths([:api_accessible_content_profiles_path, {id: 'access', format: :json}]),
             page_user: user_profile.username,
             access_profile: xml_profile_provider.content_profile_for_user(user_profile)
      }
      res[:success] = res[:access_profile][:entries].empty? ? false : true
      unless res[:success]
        res[:message] = res[:access_profile][:message]
      else
        res[:message] = "AccessProfile Entries for #{user_profile.username}:#{user_profile.display_name} Options=#{user_profile.user_options.join(',')}"
      end
      Rails.logger.warn "#{self.class.name}.#{__method__}() returns: #{res}"

      res
    end

    ##
    # Builds display package for a single username
    # returns:
    # {:success=>false,
    #  :message=>"No content profile data available for Vendor Secondary User",
    #  :user_options=>["VendorSecondary", "0099"],
    #  :accessible_content_url=>"/profiles/api_accessible_content.json?id=content",
    #  :page_user=>"vstester",
    #  :content_profile=>{
    #     :success=>false,
    #     :message=>"No content profile data available for Vendor Secondary User",
    #     :username=>"vstester", :entries=>[]
    #     }
    # }
    #
    # -- OR --
    #
    # {:success=>true,
    #  :message=>"ContentProfile Entry for vptester, VendorPrimary:Partner Manager, Options=VendorPrimary,0099",
    #  :user_options=>["VendorPrimary", "0099"],
    #  :accessible_content_url=>"/profiles/api_accessible_content.json?id=content",
    #  :page_user=>"vptester",
    #  :content_profile=>{
    #    :pak=>"0c3d2ff173f9600f2b7efb07bfada939",
    #    :profile_type=>"VendorPrimary",
    #    :profile_type_description=>"Partner Manager",
    #    :provider=>"SknService::Bcrypt",
    #    :username=>"vptester",
    #    :display_name=>"Vendor Primary User",
    #    :email=>"appdev4@localhost.com",
    #    :assigned_group=>["VendorPrimary"],
    #    :user_options=>["VendorPrimary", "0099"],
    #    :entries=>[
    #      {:content_value=>["*.pdf"],
    #       :content_type=>"Activity",
    #       :content_type_description=>"Project Status Reports",
    #       :topic_value=>["0099"],
    #       :topic_type=>"Partner",
    #       :topic_type_description=>"This Corporate Account",
    #       :description=>"Access Relationship Documents",
    #       :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Status Reports"}]],
    #       :topic_selects=>[["0099", 0, {:"data-description"=>"This Corporate Account"}]],
    #       :user_options=>["VendorPrimary", "0099"],
    #       :username=>"vptester"
    #      },
    #      {:content_value=>["*.pdf"], :content_type=>"FileDownload", :content_type_description=>"Project Related Images", :topic_value=>["VendorPrimary"], :topic_type=>"UserGroups", :topic_type_description=>"Shared access to project working files", :description=>"Shared access to project working files", :content_selects=>[["*.pdf", 0, {:"data-description"=>"Project Related Images"}]], :topic_selects=>[["VendorPrimary", 0, {:"data-description"=>"Shared access to project working files"}]], :user_options=>["VendorPrimary", "0099"], :username=>"vptester"}
    #    ],
    #    :success=>true
    #  }
    # }
    #
    def content_profile_package(user_profile=nil)
      @accessible_type = "content" # [:access, :content]
        raise(Utility::Errors::NotFound, "No profile data available for user") unless user_profile.present?

      res = {
         success: true,
         message: "",
         user_options: (user_profile.user_options || []),
         accessible_content_url: page_action_paths([:api_accessible_content_profiles_path, {id: 'content', format: :json}]),
         page_user: user_profile.username,
         content_profile: db_profile_provider.content_profile_for_user(user_profile)
      }
      res[:success] = res[:content_profile][:entries].empty? ? false : true
      unless res[:success]
        res[:message] = res[:content_profile][:message]
      else
        res[:message] = "ContentProfile Entry for #{user_profile.username}, #{res[:content_profile][:profile_type]}:#{res[:content_profile][:profile_type_description]}, Options=#{user_profile.user_options.join(',')}"
      end
      Rails.logger.warn "#{self.class.name}.#{__method__}() returns: #{res}"

      res
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
      cpe = HashWithIndifferentAccess.new(params) # [:access=role, :content=content]
      pg_u = get_page_user(cpe[:username] , cpe[:id])
        raise(Utility::Errors::NotFound, "No profile data available for user") unless pg_u.present?

      cpe[:profile] = cpe[:id]
      cpe[:id] = pg_u.id
      Rails.logger.debug "#{self.class}##{__method__} results => #{cpe}"

      # Returns an empty Array on Error, or Array of Hashes on Success
      [adapter_for_content_profile_entry(cpe).available_content_list(cpe), pg_u.display_name]
    end

    def get_content_object_api(params)
       adapter_for_content_profile_entry(params).retrieve_content_object(params)
    end

    def get_demo_content_object_api(params)
      adapter_for_content_profile_entry(params).retrieve_demo_content_object(params, current_user)
    end

    ##
    # Supporting ContentProfilesController Actions
    #  Parameters: {"utf8"=>"✓", "id"=>"75d521ee406b03aee02e2a4bfe05b660", "username"=>"vstester", "profile_type_id"=>"{:data=>{:description=>\"Partner Staff\"}}", "button"=>"content-profile-modal"}
    def create_content_profile_with_profile_type_id(params)
      pt = ProfileType.find_by(id: (params['profile_type_id'] || params[:profile_type_id]))
      u = get_page_user((params[:username] || params['username']))
      cp = db_profile_provider.create_content_profile_for(u, pt.name)
      cp.present?
    end
    def update_content_profile_with_profile_type_id(params)
      cp =db_profile_provider.update_content_profile_for(params['id'], params['profile_type_id'].to_i)
      cp.present?
    end
    def destroy_content_profile_by_pak(params)
      cp =db_profile_provider.destroy_content_profile_by_pak(params['id'])
      cp.present?
    end

    def create_content_profile_entries(params)
      cp =db_profile_provider.create_content_profile_entry_by_ids(params)
      cp.present?
    end
    def destroy_content_profile_entry(params)
      cp =db_profile_provider.destroy_content_profile_entry_with_pak_and_id(params['pak'], params['id'])
      cp.present?
    end

  end
end
