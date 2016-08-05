##
# Creates initial data load for content profile
#
# http://guides.rubyonrails.org/form_helpers.html#building-complex-forms
#
#
##
# HBTM needs a key prefix (content_type_opts_attributes),
# BO/HO doesn't need the key prefix (content_type_attributes)
##
##
# Outcomes
#
# {UUID/BranchOwner} => [
#     PAK/ProfileType    {Commission/Branch/0034 => "CommRptID,CommCsvID,ExperRptID"},
#                        {Notification/Account/99 => "AdvCancel,Cancel"},
#                        {Operations/LicensedStates/USA => "21,30,34,45"}
# ]                      ContentType/TopicType/TopicTypeOpts => ContentTypeOpts


module Utility
  class ContentProfileTestDataLoader

    def initialize
      Rails.logger.info "#{self.class.name}##{__method__} Ready to do good work."
    end

    def refresh_content_profiles_data_model
      results = true

      puts "[Start] Refreshing Full ContentProfile Data Model: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating Full ContentProfile Data Model."
      ## Begin Good Work

      report_current_population

        clear_existing_data

        create_proper_content_model_with_selections unless create_profile_types.empty?

      report_current_population

      ## End Good Work
      puts "[End] Refreshing Full ContentProfile Data Model: [Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Refreshing Full ContentProfile Data Model."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Refreshing Full ContentProfile Data Model; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[End] Refreshing Full ContentProfile Data Model: [Failed!]"
      false
    end

    # returns a Array of Hashes
    # First record is heading compoonents
    # Returns {:heading_hdr,
    #          :heading_sep,
    #          :entry_count,
    #          :all_or_content_only,
    #          entries: [{:index, :content_type_flag, :uri, :description, :userdata, :formatted_line},...]}
    def report_access_registry_xml_listing(all_entries=false, local_prt=true) # defaults to content profile entries
      results = {}

      print "[Start] AccessRegistry XML Listing: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) AccessRegistry XML Listing. Entries: #{Secure::AccessRegistry.get_ar_resource_keys.length} "
      ## Begin Good Work


      results = {
        heading_hdr: "Index                       :URI value  Description                                      :UserData",
        heading_sep: "-----  -------------------------------  -----------------------------------------------  -------------------------------",
        entry_count: Secure::AccessRegistry.get_ar_resource_keys.length,
        all_or_content_only: all_entries,
        entries: []
      }

      Secure::AccessRegistry.get_ar_resource_keys.each_with_index do |ar,index|
        content_flag = Secure::AccessRegistry.get_resource_type(ar)
        next unless (all_entries ?  true : content_flag )
        results[:entries] << {
            index: index,
            content_type_flag: content_flag,
            uri: ar.to_s,
            description: Secure::AccessRegistry.get_resource_description(ar),
            userdata: Secure::AccessRegistry.get_resource_userdata(ar),
            formatted_line: "#{'%05d' % index} #{ar.to_s.rjust(32,' ')}  #{'%48s' % Secure::AccessRegistry.get_resource_description(ar).ljust(48,' ')} #{Secure::AccessRegistry.get_resource_userdata(ar)}"
                             }
      end

      if local_prt
        puts "AccessProfiles:"
        puts "\t Entries: #{results[:entry_count]} \n"
        puts results[:heading_hdr]
        puts results[:heading_sep]
          results[:entries].each {|line| puts line[:formatted_line]}
        puts results[:heading_sep]
        puts "\n"
      end

      ## End Good Work
      puts "[End] AccessRegistry XML Listing: [Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) AccessRegistry XML Listing."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) AccessRegistry XML Listing; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[End] AccessRegistry XML Listing: [Failed!]"
      false
    end


    def report_current_population
      results = true

      puts "[Start] ContentProfile Data Model Population: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) ContentProfile Data Model Population."
      ## Begin Good Work
      results  = "\n\nContentProfiles Population:\n"
      results += "\t        UserProfiles: #{User.count}\n"
      results += "\t      ContentProfile: #{ContentProfile.count}\n"
      results += "\t         ProfileType: #{ProfileType.count}\n"
      results += "\n"
      results += "\t ContentProfileEntry: #{ContentProfileEntry.count}\n"
      results += "\n"
      results += "\t         ContentType: #{ContentType.count}\n"
      results += "\t      ContentTypeOpt: #{ContentTypeOpt.count}\n"
      results += "\n"
      results += "\t           TopicType: #{TopicType.count}\n"
      results += "\t        TopicTypeOpt: #{TopicTypeOpt.count}\n"
      results += "\n"

      puts results
      Rails.logger.info "#{self.class.name}##{__method__}(Results) #{results}"

      ## End Good Work
      puts "[End] ContentProfile Data Model Population: [Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) ContentProfile Data Model Population."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) ContentProfile Data Model Population; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[End] ContentProfile Data Model Population: [Failed!]"
      false
    end

    def clear_existing_data
      results = true

      print "[Start] Clearing ContentProfile Tables: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Clearing ContentProfile Tables."
      ## Begin Good Work

      ContentProfile.destroy_all   # TODO: These two might be all that is needed, based on referential integrity
      ProfileType.destroy_all

      ContentProfileEntry.destroy_all
      ContentType.destroy_all
      # ContentTypeOpt.destroy_all
      TopicType.destroy_all
      # TopicTypeOpt.destroy_all

      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Clearing ContentProfile Tables."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Clearing ContentProfile Tables; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end

    def create_profile_types
      print "[Start] Creating ProfileType Table: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating ProfileType Table."
      ## Begin Good Work

      pt = [
          {name: "Developer",         description: "Open Source Independent Consultancy"},
          {name: "Manager",           description: "Corporate Managers"},
          {name: "EmployeePrimary",   description: "Department Managers"},
          {name: "EmployeeSecondary", description: "Corporate Staff"},
          {name: "BranchPrimary",     description: "Branch Manager"},
          {name: "BranchSecondary",   description: "Branch Staff"},
          {name: "VendorPrimary",     description: "Partner Manager"},
          {name: "VendorSecondary",   description: "Partner Staff"}
      ]

      results = []
      results = ProfileType.create!(pt)

      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Creating ProfileType Table."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Creating ProfileType Table; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end

    # Does create the full content profile,
    # Create ContentType, TopicType, and ContentProfileEntries
    # Wire up ContentProfileEntries and create ContentProfile
    def create_proper_content_model_with_selections
      results = true

      print "[Start] Creating Full ContentProfile Data Model: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating Full ContentProfile Data Model."
      ## Begin Good Work

      ContentType.create!([
          {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "String",
           content_type_opts_attributes: {
               "0" => {value: "*.pdf", type_name: "Commission", description: "Document store Commision Document Type ID" },
               "1" => {value: "*.csv", type_name: "Commission", description: "Document store Commision CSV Document Type ID" },
               "2" => {value: "*.log", type_name: "Commission", description: "Document store Branch Experience Document Type ID"} }
          },
          {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
           content_type_opts_attributes: {
               "0" => {value: "AdvCancel", type_name: "Notification", description: "Advance Cancel" },
               "1" => {value: "FutCancel", type_name: "Notification", description: "Future Cancel" },
               "2" => {value: "Cancel",    type_name: "Notification", description: "Cancel" } }
          },
          {name: "LicensedStates",   description: "Business Operational Metric", value_data_type: "Integer",
           content_type_opts_attributes: {
               "0" => {value: "21", type_name: "LicensedStates", description: "Michigan"},
               "1" => {value: "9",  type_name: "LicensedStates",  description: "Ohio"},
               "2" => {value: "23", type_name: "LicensedStates", description: "Illinois"} }
          },
          {name: "Activity",   description: "Partner Relationship Reports", value_data_type: "String",
           content_type_opts_attributes: {
               "0" => {value: "*.pdf", type_name: "Activity", description: "Document store Project Status Report Document Type ID"}
           }
          },
          {name: "FileDownload",   description: "Project Related Images", value_data_type: "String",
           content_type_opts_attributes: {
               "0" => {value: "*.png", type_name: "FileDownload", description: "Project Related by Document Type PNG"},
               "1" => {value: "*.jpg", type_name: "FileDownload", description: "Project Related by Document Type JPEG"},
               "2" => {value: "*.pdf", type_name: "FileDownload", description: "Project Related by Document Type PDF"},
               "3" => {value: "*.log", type_name: "FileDownload", description: "Project Related by Document Type LOG"}
           }
          }
      ])

      TopicType.create!([
          {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "N",
           topic_type_opts_attributes: {
               "0" => {value: "0034", type_name: "Branch", description: "South Branch Number"},
               "1" => {value: "0037", type_name: "Branch", description: "North Branch Number"},
               "2" => {value: "0040", type_name: "Branch", description: "West Branch Number"} }
          },
          {name: "Partner", description: "This Corporate Account",  value_based_y_n: "N",
           topic_type_opts_attributes: {
               "0" => {value: "0099", type_name: "Partner", description: "Skoona Development Account"}}
          },
          {name: "UserGroups", description: "Shared access to project working files",  value_based_y_n: "N",
           topic_type_opts_attributes: {
               "0" => {value: "Manager",           type_name: "UserGroups", description: "Project Workfiles"},
               "1" => {value: "EmployeePrimary",   type_name: "UserGroups", description: "Project Workfiles"},
               "2" => {value: "EmployeeSecondary", type_name: "UserGroups", description: "Project Workfiles"},
               "3" => {value: "VendorPrimary",     type_name: "UserGroups", description: "Project Workfiles"},
               "4" => {value: "VendorSecondary",   type_name: "UserGroups", description: "Project Workfiles"},
               "5" => {value: "BranchPrimary",     type_name: "UserGroups", description: "Project Workfiles"},
               "6" => {value: "Developer",         type_name: "UserGroups", description: "Project Workfiles"}
           }
          }
      ])

      cpe_primary = []
      [
       ['Commission',     ['*.pdf'],     'Branch',  ['0034'], 'Access Branch Commission PDF Files'],
       ['Notification',   ['AdvCancel'], 'Branch',  ['0034'], 'Notify Branch of Policy Events'],
       ['LicensedStates', ['21','9','23'], 'Branch',  ['0034'], 'Licensed to operate in state'],
       ['Activity',       ['*.pdf'],     'Partner', ['0099'], 'Partner Relationship Reports'],

       ['Commission',     ['*.csv'],     'Branch',  ['0037'], 'Access Branch Commission CSV Files'],
       ['Notification',   ['Cancel'],    'Branch',  ['0037'], 'Notify Branch of Policy Events'],
       ['LicensedStates', ['23'],        'Branch',  ['0037'], 'Licensed to operate in state'],

       ['Commission',     ['*.log'],     'Branch',  ['0040'], 'Access Branch Commission LOG Files'],
       ['Notification',   ['FutCancel'], 'Branch',  ['0040'], 'Notify Branch of Policy Events'],

       ['FileDownload',   ['*.pdf'], 'UserGroups',  ['EmployeePrimary'], 'Shared access to project working files'],
       ['FileDownload',   ['*.png'], 'UserGroups',  ['EmployeePrimary'], 'Shared access to project working files'],
       ['FileDownload',   ['*.jpg'], 'UserGroups',  ['EmployeePrimary'], 'Shared access to project working files'],
       ['FileDownload',   ['*.log'], 'UserGroups',  ['EmployeePrimary'], 'Shared access to project working files']

      ].each do |req|
        cchoice = selections_choose_for(req[1], selections_for_content_type(req[0], true))
        tchoice = selections_choose_for(req[3], selections_for_topic_type(req[2], true))
        cpe_primary << create_content_profile_entry_for(req.last, tchoice, cchoice)
      end

      cpe_sec = []
      [
          ['Commission',     ['*.pdf'],     'Branch',  ['0034'], 'Access Branch Commission PDF Files'],
          ['Notification',   ['AdvCancel'], 'Branch',  ['0034'], 'Notify Branch of Policy Events'],
          ['LicensedStates', ['21'],        'Branch',  ['0034'], 'Licensed to operate in state'],
          ['Activity',       ['*.pdf'],     'Partner', ['0099'], 'Partner Relationship Reports'],

          ['Commission',     ['*.log'],     'Branch',  ['0040'], 'Access Branch Commission LOG Files'],
          ['Notification',   ['FutCancel'], 'Branch',  ['0040'], 'Notify Branch of Policy Events'],

          ['FileDownload',   ['*.pdf'], 'UserGroups',  ['EmployeeSecondary'], 'Shared access to project working files'],
          ['FileDownload',   ['*.pdf'], 'UserGroups',  ['BranchPrimary'], 'Shared access to project working files']

      ].each do |req|
        cchoice = selections_choose_for(req[1], selections_for_content_type(req[0], true))
        tchoice = selections_choose_for(req[3], selections_for_topic_type(req[2], true))
        cpe_sec << create_content_profile_entry_for(req.last, tchoice, cchoice)
      end

      cpe_vendor = []
      [
          ['Activity',       ['*.pdf'],     'Partner', ['0099'], 'Partner Relationship Reports'],
          ['FileDownload',   ['*.log'],  'UserGroups',  ['VendorPrimary'], 'Shared access to project working files']

      ].each do |req|
        cchoice = selections_choose_for(req[1], selections_for_content_type(req[0], true))
        tchoice = selections_choose_for(req[3], selections_for_topic_type(req[2], true))
        cpe_vendor << create_content_profile_entry_for(req.last, tchoice, cchoice)
      end

      # loop thru users
      res = Secure::UserProfile.page_users.each do |u|
        next if u.user_options.empty? or u.user_options.include?("VendorSecondary")

        cp = create_content_profile_for(u, u.assigned_groups.first)

        entries = case u.assigned_groups.first
                    when 'Developer', 'Manager', 'EmployeePrimary'
                      cpe_primary
                    when 'EmployeeSecondary', 'BranchPrimary'
                      cpe_sec
                    else
                      cpe_vendor
                  end

        assign_content_profile_entry_to(cp, entries)

      end


      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Creating Full ContentProfile Data Model."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Creating Full ContentProfile Data Model; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end


    protected

    def selections_for_content_type(type, clean=false)
      choices = ContentType.where(name: type).includes(:content_type_opts).map do |recs|
        {type: recs.attributes,
         opts: recs.content_type_opts.map(&:attributes)}
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    def selections_for_topic_type(type, clean=false)
      choices = TopicType.where(name: type).includes(:topic_type_opts).map do |recs|
        {type: recs.attributes,
         opts: recs.topic_type_opts.map(&:attributes)}
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    def selections_choose_for(a_choices, ah_type_values, clean=true)
      choices = []
      ah_type_values.each do |atv|
        chosen = atv[:opts].select {|opt| opt["value"].in?(a_choices)}.flatten
        choices << {type: atv[:type], opts: chosen} if chosen.present?
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    # topic_choice and content_choice should be single hashes
    def create_content_profile_entry_for(cpe_desc, topic_choice, content_choice)
      cvs = content_choice.is_a?(Hash) ? content_choice : content_choice.first
      tvs = topic_choice.is_a?(Hash) ? topic_choice : topic_choice.first
      ContentProfileEntry.create!({
          description: cpe_desc,
          content_value: cvs[:opts].map {|v| v["value"] }.flatten,
          content_type: cvs[:type]["name"],
          content_type_description: cvs[:type]["description"],
          topic_value: tvs[:opts].map {|v| v["value"] }.flatten,
          topic_type: tvs[:type]["name"],
          topic_type_description: tvs[:type]["description"]
      })
    end

    def create_content_profile_for(user_p, profile_type_name )
      ContentProfile.create!({
          person_authentication_key: user_p.person_authenticated_key,
          profile_type_id: ProfileType.find_by(name: profile_type_name).try(:id),
          authentication_provider: "SknService::Bcrypt",
          username: user_p.username,
          display_name: user_p.display_name,
          email: user_p.email
      })
    end

    def assign_content_profile_entry_to(profile_obj, profile_entry_obj)
      profile_obj.content_profile_entries << profile_entry_obj
      profile_obj.save!
      profile_obj.content_profile_entries.reload
      profile_obj
    end

    def remove_dates_and_ids_from_choices(choices)
      targets = ["id", "created_at", "updated_at", "content_type_id", "topic_type_id"]
      choices.each do |choice|
        choice[:type].delete_if {|k,v| k.in?(targets) }
        choice[:opts].each {|opt| opt.delete_if {|k,v| k.in?(targets)}}
      end
      choices
    end

  end # ContentDataLoader
end # Utility