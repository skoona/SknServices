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

    def refresh_full_data_model
      results = true

      puts "[Start] Refreshing Full ContentProfile Data Model: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating Full ContentProfile Data Model."
      ## Begin Good Work

      report_current_population

        clear_existing_data

        create_full_content_profile unless create_profile_types.empty?

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
      ContentTypeOpt.destroy_all
      TopicType.destroy_all
      TopicTypeOpt.destroy_all

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
          {name: "EmployeePrimary",   description: "Corporate Managers"},
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

    def create_content_types_and_options
      print "[Start] Creating ContentType and ContentTypeOpts: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating ContentType and ContentTypeOpts."
      ## Begin Good Work

      ct  = [
          {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
            content_type_opts_attributes: {
              "0" => {value: "68601", description: "Document store Commision Document Type ID" },
              "1" => {value: "68602", description: "Document store Commision CSV Document Type ID" },
              "2" => {value: "68603", description: "Document store Branch Experience Document Type ID" }}
          },
          {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
            content_type_opts_attributes: {
              "0" => {value: "AdvCancel", description: "Advance Cancel" },
              "1" => {value: "FutCancel", description: "Future Cancel" },
              "2" => {value: "Cancel",    description: "Cancel" }}
          },
          {name: "Operations",   description: "Business Operational Metric", value_data_type: "Integer",
            content_type_opts_attributes: {
              "0" => {value: "21", description: "Michigan"},
              "1" => {value: "9",  description: "Ohio"},
              "2" => {value: "23", description: "Illinois"}}
          }
      ]

      results = []
      results = ContentType.create!(ct)

      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Creating ContentType and ContentTypeOpts."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Creating ContentType and ContentTypeOpts; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end

    def create_topic_types_and_options
      print "[Start] Creating TopicType and TopicTypeOpts: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating TopicType and TopicTypeOpts."
      ## Begin Good Work

      tt  = [
          {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
              "0" => {value: "0034", description: "Some Branch Number"},
              "1" => {value: "1001", description: "Another Branch Number"},
              "2" => {value: "0037", description: "More Agencies"} }
          },
          {name: "Account", description: "Account Action again for a specific set of account", value_based_y_n: "N",
            topic_type_opts_attributes: {
              "0" => {value: "Branch", description: "All Branch Accounts"},
              "1" => {value: "Producer",  description: "All Producer Accounts"},
              "2" => {value: "None",   description: "No Branch Producer Options"}}
          },
          {name: "LicensedStates", description: "Producer Actions", value_based_y_n: "Y",
            topic_type_opts_attributes: {
              "0" => {value: "USA", description: "United States of America"},
              "1" => {value: "CAN", description: "Canada"}}
          }
      ]

      results = []
      results = TopicType.create!(tt)

      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Creating TopicType and TopicTypeOpts."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Creating TopicType and TopicTypeOpts; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end

    def create_content_profile_entries
      results = true

      print "[Start] Creating ContentProfileEntries: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating ContentProfileEntries."
      ## Begin Good Work

      cpe = [
        {topic_value: [],     content_value: [], description: 'Determine which branch documents can be seen',
              content_types_attributes: {
                "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
                content_type_opts_attributes: {
                  "0" => {value: "68601", description: "Document store Commision Document Type ID" },
                  "1" => {value: "68602", description: "Document store Commision CSV Document Type ID" },
                  "2" => {value: "68603", description: "Document store Branch Experience Document Type ID"} }}
            },
              topic_types_attributes: {
                "0" => {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "Y",
                topic_type_opts_attributes: {
                  "0" => {value: "0034", description: "Some Branch Number"},
                  "1" => {value: "1001", description: "Another Branch Number"},
                  "2" => {value: "0037", description: "More Agencies"} }}}
        },
        {topic_value: [],    content_value: [], description: 'Determine which accounts will have notification sent',
              content_types_attributes: {
                "0" => {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
                content_type_opts_attributes: {
                  "0" => {value: "AdvCancel", description: "Advance Cancel" },
                  "1" => {value: "FutCancel", description: "Future Cancel" },
                  "2" => {value: "Cancel",    description: "Cancel" } }}
            },
              topic_types_attributes: {
                "0" => {name: "Account", description: "Account Action again for a specific set of account", value_based_y_n: "N",
                topic_type_opts_attributes: {
                  "0" => {value: "Branch", description: "All Branch Accounts"},
                  "1" => {value: "Producer",  description: "All Producer Accounts"},
                  "2" => {value: "None",   description: "No Branch Producer Options"} }}}
        },
        {topic_value: [], content_value: [], description: 'Determine which States producer may operate in.',
              content_types_attributes: {
                "0" => {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer",
                content_type_opts_attributes: {
                  "0" => {value: "21", description: "Michigan"},
                  "1" => {value: "9",  description: "Ohio"},
                  "2" => {value: "23", description: "Illinois"} }}
            },
              topic_types_attributes: {
                "0" => {name: "LicensedStates", description: "Producer Actions", value_based_y_n: "Y",
                topic_type_opts_attributes: {
                  "0" => {value: "USA", description: "United States of America"},
                  "1" => {value: "CAN", description: "Canada"} }}}
        }
      ]

      results = []
      results = ContentProfileEntry.create!(cpe)

      ## End Good Work
      puts "[Success!]"
      Rails.logger.info "#{self.class.name}##{__method__}(SUCCESS) Creating ContentProfileEntries."
      results
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(FAILED) Creating ContentProfileEntries; Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      puts "[Failed!]"
      false
    end


    def create_full_content_profile
      results = true

      print "[Start] Creating Full ContentProfile Data Model: "
      Rails.logger.info "#{self.class.name}##{__method__}(START) Creating Full ContentProfile Data Model."
      ## Begin Good Work

      cpep = [
        {topic_value: [],     content_value: [], description: 'Determine which branch documents can be seen',
            content_types_attributes: {
            "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "68601", description: "Document store Commision Document Type ID" },
            "1" => {value: "68602", description: "Document store Commision CSV Document Type ID" },
            "2" => {value: "68603", description: "Document store Branch Experience Document Type ID"} }}
          },
            topic_types_attributes: {
            "0" => {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "0034", description: "South Branch Number"},
            "1" => {value: "0037", description: "North Branch Number"},
            "2" => {value: "0040", description: "West Branch Number"} }}}
        },
        {topic_value: [],    content_value: [], description: 'Determine which accounts will have notification sent',
            content_types_attributes: {
            "0" => {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
            content_type_opts_attributes: {
            "0" => {value: "AdvCancel", description: "Advance Cancel" },
            "1" => {value: "FutCancel", description: "Future Cancel" },
            "2" => {value: "Cancel",    description: "Cancel" } }}
          },
            topic_types_attributes: {
            "0" => {name: "Account", description: "Account Action again for a specific set of account", value_based_y_n: "N",
            topic_type_opts_attributes: {
            "0" => {value: "1601", description: "All Branch Accounts"},
            "1" => {value: "1602", description: "All Branch Accounts"} }}}
        },
        {topic_value: [], content_value: [], description: 'Determine which States producer may operate in.',
            content_types_attributes: {
            "0" => {name: "Operations",   description: "Business Operational Metric", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "21", description: "Michigan"},
            "1" => {value: "9",  description: "Ohio"},
            "2" => {value: "23", description: "Illinois"} }}
          },
            topic_types_attributes: {
            "0" => {name: "LicensedStates", description: "Producer Actions", value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "USA", description: "United States of America"} }}}
        }
      ]

      cpes = [
        {topic_value: [],     content_value: [], description: 'Determine which branch documents can be seen',
            content_types_attributes: {
            "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "68613", description: "Document store Branch Experience Document Type ID"} }}
          },
            topic_types_attributes: {
            "0" => {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "0037", description: "North Branch Number"}}}}
        },
        {topic_value: [],    content_value: [], description: 'Determine which accounts will have notification sent',
            content_types_attributes: {
            "0" => {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
            content_type_opts_attributes: {
            "0" => {value: "AdvCancel", description: "Advance Cancel" } }}
          },
            topic_types_attributes: {
            "0" => {name: "Account", description: "Account Action again for a specific set of account", value_based_y_n: "N",
            topic_type_opts_attributes: {
            "1" => {value: "1602",  description: "All Producer Accounts"} }}}
        }
      ]

      cpev = [
        {topic_value: [], content_value: [], description: 'Relationship Activity Reports',
            content_types_attributes: {
            "0" => {name: "Activity",   description: "Project Status Reports", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "0099", description: "Document store Project Status Report Document Type ID"} }}
          },
            topic_types_attributes: {
            "0" => {name: "Partner",  description: "This Corporate Account",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "0099", description: "Skoona Development Account"}}}}
        }
      ]

      cpep_recs = ContentProfileEntry.create!(cpep)
      cpes_recs = ContentProfileEntry.create!(cpes)
      cpev_recs = ContentProfileEntry.create!(cpev)

      # loop thru users
      res = User.find_each do |u|
        next if 'VendorSecondary'.eql?( u.assigned_groups.first )
        rec = ContentProfile.new
        rec.person_authentication_key = u.person_authenticated_key
        rec.authentication_provider = 'SknService::Bcrypt'
        rec.username = u.username
        rec.display_name = u.display_name
        rec.email = u.email
        rec.save
        rec.reload
        rec.profile_type = ProfileType.find_by(name: u.assigned_groups.first)
        rec.content_profile_entries = case u.assigned_groups.first
                                        when 'EmployeePrimary'
                                          cpep_recs
                                        when 'EmployeeSecondary'
                                          cpes_recs
                                        when 'BranchPrimary'
                                          cpes_recs
                                        else
                                          cpev_recs
                                      end
        rec.save!
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



  end # ContentDataLoader
end # Utility