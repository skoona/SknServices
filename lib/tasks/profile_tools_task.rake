##
# lib/tasks/profile_tools_task.rake
#
# Preloads the ContentProfile Tables
#
# -- rake access_registry:preload:db_profiles
# -- rake access_registry:reports:db_profiles
# -- rake access_registry:reports:xml_profiles
#
# Args are taken as a Hash: {:arg1=>"false"}
#     task :xml_profiles, [:arg1] => :environment do |t, args|
#     task :xml_profiles, [:arg1,:arg2] => :environment do |t, args|
#
# "0" => {} is an index, it needs to be uniq and can be any value like time microseconds


namespace :access_registry do

  namespace :admin do
    desc 'Drops ContentProfiles tables and reloads them.'
    task db_profiles: [:environment,
                       "reports:db_profiles",
                       "preload:db_profiles" ] do
      puts "\nCompleted"
    end

  end


  namespace :preload do

    desc 'Preloads the data-based ContentProfiles.'
    task db_profiles: [:environment, :drop_profiles, :create_topic_types,
                       :create_profile_types, :create_content_types] do |t, args|
      begin
        puts "ContentProfiles:"
        puts "\t      ContentProfile: #{ContentProfile.count}"
        puts "\t         ProfileType: #{ProfileType.count}"
        puts ""
        puts "\t ContentProfileEntry: #{ContentProfileEntry.count}"
        puts ""
        puts "\t         ContentType: #{ContentType.count}"
        puts "\t      ContentTypeOpt: #{ContentTypeOpt.count}"
        puts ""
        puts "\t           TopicType: #{TopicType.count}"
        puts "\t        TopicTypeOpt: #{TopicTypeOpt.count}"
        puts "\n"
      end
    end

    desc 'Drops ContentProfiles tables'
    task drop_profiles: :environment do
      begin
        print "\tStart Dropping ContentProfile(all) tables."
        ContentProfile.destroy_all
        ProfileType.destroy_all
        ContentProfileEntry.destroy_all
        ContentType.destroy_all
        ContentTypeOpt.destroy_all
        TopicType.destroy_all
        TopicTypeOpt.destroy_all
        puts "Success!."
      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed!."
        false
      end
    end

    desc 'Creates the ContentType and ContentTypeOpts entries..'
    task create_content_types: :environment do |t, args|
      begin
        print "\tStart ContentTypes and ContentOptions: "

        ct  = [
            {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
             content_type_opts_attributes: {
                 "0" => {value: "68601", description: "Imageright Commision Document Type ID" },
                 "1" => {value: "68602", description: "Imageright Commision CSV Document Type ID" },
                 "2" => {value: "68603", description: "Imageright Agency Experience Document Type ID" }}
            },
            {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
             content_type_opts_attributes: {
                 "0" => {value: "AdvCancel", description: "Advance Cancel" },
                 "1" => {value: "FutCancel", description: "Future Cancel" },
                 "2" => {value: "Cancel",    description: "Cancel" }}
            },
            {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer",
             content_type_opts_attributes: {
                 "0" => {value: "21", description: "Michigan"},
                 "1" => {value: "9",  description: "Ohio"},
                 "2" => {value: "23", description: "Illinois"}}
            }
        ]

        c_types = ContentType.create!(ct)

        puts "Success!"
        c_types
      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed!"
        []
      end
    end

    desc 'Creates the TopicType and TopicTypeOpts entries..'
    task create_topic_types: :environment do |t, args|
      begin
        print "\tStart TopicType and TopicTypeOpts : "

        tt  = [
            {name: "Agency",  description: "Agency Actions for a specific agency",  value_based_y_n: "Y",
             topic_type_opts_attributes: {
                 "0" => {value: "0034", description: "Some Agency Number"},
                 "1" => {value: "1001", description: "Another Agency Number"},
                 "2" => {value: "0037", description: "More Agencies"} }
            },
            {name: "Account", description: "Account Action again for a specific set of account", value_based_y_n: "N",
             topic_type_opts_attributes: {
                 "0" => {value: "Agency", description: "All Agency Accounts"},
                 "1" => {value: "Agent",  description: "All Agent Accounts"},
                 "2" => {value: "None",   description: "No Agency Agent Options"}}
            },
            {name: "LicensedStates", description: "Agent Actions", value_based_y_n: "Y",
             topic_type_opts_attributes: {
                 "0" => {value: "USA", description: "United States of America"},
                 "1" => {value: "CAN", description: "Canada"}}
            }
        ]

        t_types = TopicType.create!(tt)

        puts "Success!."
        t_types
      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed"
        []
      end
    end

    desc 'Creates ProfileType records.'
    task create_profile_types:  :environment do |t, args|
      begin
        print "\tCreating ProfileTypes: "
        pt  = [
            {name: "AgencyPrimary",   description: "Agency Super User"},
            {name: "AgencySecondary", description: "Limited User"},
            {name: "EmployeePrimary",   description: "BMI Admin User"},
            {name: "EmployeeSecondary", description: "BMI Limited User"},
            {name: "VendorPrimary",   description: "External Vendor Primary Role"},
            {name: "VendorSecondary", description: "External Vendor Secondary Role"}
        ]

        pt_types = []
        pt_types = ProfileType.create!(pt)

        puts "Success!."
        pt_types

      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed"
        []
      end
    end

    desc 'Creates ContentProfileEntry records.'
    task create_content_profile_entries:  :environment do |t, args|
      begin

        Rake::Task['access_registry:preload:drop_profiles'].invoke

        print "\tCreating ContentProfileEntry, ContentType/ContentTypeOpts, TopicType/TopicTypeOpts: "
        res = []

        # HBTM needs a key prefix (content_type_opts_attributes),
        # BO/HO doesn't need the key prefix (content_type_attributes)
        cpe = [
            {topic_value: ["Agency"],     content_value: [], description: 'Determine which agency documents can be seen',
            content_types_attributes: {
            "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "68601", description: "Imageright Commision Document Type ID" },
            "1" => {value: "68602", description: "Imageright Commision CSV Document Type ID" },
            "2" => {value: "68603", description: "Imageright Agency Experience Document Type ID"} }}
        },
            topic_types_attributes: {
            "0" => {name: "Agency",  description: "Agency Actions for a specific agency",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "0034", description: "Some Agency Number"},
            "1" => {value: "1001", description: "Another Agency Number"},
            "2" => {value: "0037", description: "More Agencies"} }}}
        },
            {topic_value: ["Account"],    content_value: [], description: 'Determine which accounts will have notification sent',
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
            "0" => {value: "Agency", description: "All Agency Accounts"},
            "1" => {value: "Agent",  description: "All Agent Accounts"},
            "2" => {value: "None",   description: "No Agency Agent Options"} }}}
        },
            {topic_value: ["LicensedStates"], content_value: [], description: 'Determine which States agent may operate in.',
            content_types_attributes: {
            "0" => {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "21", description: "Michigan"},
            "1" => {value: "9",  description: "Ohio"},
            "2" => {value: "23", description: "Illinois"} }}
        },
            topic_types_attributes: {
            "0" => {name: "LicensedStates", description: "Agent Actions", value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "USA", description: "United States of America"},
            "1" => {value: "CAN", description: "Canada"} }}}
        }
        ]

        res = ContentProfileEntry.create!(cpe)

        puts "Success!."
        res
      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed"
        []
      end
    end


    desc 'Creates ContentProfile records.'
    task create_content_profiles:  :environment do |t, args|
      begin

        Rake::Task['access_registry:preload:drop_profiles'].invoke
        Rake::Task['access_registry:reports:db_profiles'].invoke
        Rake::Task['access_registry:preload:create_profile_types'].invoke

        print "\tCreating ContentProfile, ContentProfileEntry, ContentType/ContentTypeOpts, TopicType/TopicTypeOpts: "
        res = []

        # HBTM needs a key prefix (content_type_opts_attributes),
        # BO/HO doesn't need the key prefix (content_type_attributes)
        cpep = [
            {topic_value: [],     content_value: [], description: 'Determine which agency documents can be seen',
             content_types_attributes: {
                "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
                 content_type_opts_attributes: {
                     "0" => {value: "68601", description: "Imageright Commision Document Type ID" },
                     "1" => {value: "68602", description: "Imageright Commision CSV Document Type ID" },
                     "2" => {value: "68603", description: "Imageright Agency Experience Document Type ID"} }}
             },
             topic_types_attributes: {
                "0" => {name: "Agency",  description: "Agency Actions for a specific agency",  value_based_y_n: "Y",
                 topic_type_opts_attributes: {
                     "0" => {value: "0034", description: "Some Agency Number"} }}}
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
                     "0" => {value: "Agency", description: "All Agency Accounts"} }}}
            },
            {topic_value: [], content_value: [], description: 'Determine which States agent may operate in.',
             content_types_attributes: {
                "0" => {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer",
                 content_type_opts_attributes: {
                     "0" => {value: "21", description: "Michigan"},
                     "1" => {value: "9",  description: "Ohio"},
                     "2" => {value: "23", description: "Illinois"} }}
             },
             topic_types_attributes: {
                "0" => {name: "LicensedStates", description: "Agent Actions", value_based_y_n: "Y",
                 topic_type_opts_attributes: {
                     "0" => {value: "USA", description: "United States of America"} }}}
            }
        ]

        cpes = [
          {topic_value: [],     content_value: [], description: 'Determine which agency documents can be seen',
            content_types_attributes: {
             "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
              content_type_opts_attributes: {
                "0" => {value: "68613", description: "Imageright Agency Experience Document Type ID"} }}
            },
            topic_types_attributes: {
              "0" => {name: "Agency",  description: "Agency Actions for a specific agency",  value_based_y_n: "Y",
               topic_type_opts_attributes: {
                "0" => {value: "0038", description: "Some Agency Number"}}}}
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
                "1" => {value: "Agent",  description: "All Agent Accounts"} }}}
          }
        ]

      cpev = [
        {topic_value: [],     content_value: [], description: 'Determine which agency documents can be seen',
            content_types_attributes: {
            "0" => {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
            content_type_opts_attributes: {
            "0" => {value: "68613", description: "Imageright Agency Experience Document Type ID"} }}
        },
            topic_types_attributes: {
            "0" => {name: "Agency",  description: "Agency Actions for a specific agency",  value_based_y_n: "Y",
            topic_type_opts_attributes: {
            "0" => {value: "0038", description: "Some Agency Number"}}}}
        }
        ]

        cpep_recs = ContentProfileEntry.create!(cpep)
        cpes_recs = ContentProfileEntry.create!(cpes)
        cpev_recs = ContentProfileEntry.create!(cpev)

        # loop thru users
        res = User.find_each do |u|
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
                                        when  'EmployeePrimary'
                                          cpep_recs
                                        when 'EmployeeSecondary'
                                          cpes_recs
                                        when 'AgencyPrimary'
                                          cpes_recs
                                        else
                                          cpev_recs
                                        end
          rec.save!
        end

        puts "Success!."

        Rake::Task['access_registry:reports:db_profiles'].invoke

        res
      rescue Exception => e
        Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
        puts "Failed"
        puts e.message
        []
      end
    end

  end

  namespace :reports do
    desc 'Lists Database ContentProfiles.'
    task db_profiles: :environment do |t, args|
      begin
        puts "ContentProfiles:"
        puts "\t      ContentProfile: #{ContentProfile.count}"
        puts "\t         ProfileType: #{ProfileType.count}"
        puts ""
        puts "\t ContentProfileEntry: #{ContentProfileEntry.count}"
        puts ""
        puts "\t         ContentType: #{ContentType.count}"
        puts "\t      ContentTypeOpt: #{ContentTypeOpt.count}"
        puts ""
        puts "\t           TopicType: #{TopicType.count}"
        puts "\t        TopicTypeOpt: #{TopicTypeOpt.count}"

        puts "\n"
      end
    end

    desc 'Lists XML ContentProfiles.[false|true] false is content only entries.'
    task :xml_profiles, [:arg1] => :environment do |t, args|
      begin
        depth = 'true'.eql?(args[:arg1]) || false
        puts "AccessProfiles:"
        puts "\t Entries: #{Secure::AccessRegistry.get_ar_resource_keys.length} \n"
        puts "Index                       :URI value  Description                                      :UserData"
        puts "-----  -------------------------------  -----------------------------------------------  -------------------------------"
        Secure::AccessRegistry.get_ar_resource_keys.each_with_index do |ar,index|
          next unless (depth ?  true : Secure::AccessRegistry.get_resource_type(ar) )
          puts "#{'%05d' % index} #{ar.to_s.rjust(32,' ')}  #{'%48s' % Secure::AccessRegistry.get_resource_description(ar).ljust(48,' ')} #{Secure::AccessRegistry.get_resource_userdata(ar)}"
        end
        puts "-----  -------------------------------  -----------------------------------------------  -------------------------------"
        puts "\n"
      end
    end
  end

end
