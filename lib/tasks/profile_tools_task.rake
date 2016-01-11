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


namespace :access_registry do

  namespace :preload do

    desc 'Preloads the data-based ContentProfiles.'
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
