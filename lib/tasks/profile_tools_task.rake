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
    task :refresh_db_profiles => :environment do
      Utility::ContentProfileDataLoader.new().refresh_full_data_model
    end
  end

  namespace :preload do

    desc 'Drops ContentProfiles tables'
    task :drop_profiles => :environment do
      Utility::ContentProfileDataLoader.new().clear_existing_data
    end

    desc 'Creates the ContentType and ContentTypeOpts entries..'
    task :create_content_types => :environment do |t, args|
      Utility::ContentProfileDataLoader.new().create_content_types_and_options
    end

    desc 'Creates the TopicType and TopicTypeOpts entries..'
    task :create_topic_types => :environment do |t, args|
      Utility::ContentProfileDataLoader.new().create_topic_types_and_options
    end

    desc 'Creates ProfileType records.'
    task :create_profile_types =>  :environment do |t, args|
      Utility::ContentProfileDataLoader.new().create_profile_types
    end

    desc 'Creates ContentProfileEntry records.'
    task :create_content_profile_entries =>  :environment do |t, args|
      Utility::ContentProfileDataLoader.new().create_content_profile_entries
    end

    desc 'Creates ContentProfile records.'
    task create_content_profiles:  :environment do |t, args|
      Utility::ContentProfileDataLoader.new().create_full_content_profile
    end
  end

  namespace :reports do

    desc 'Lists Database ContentProfiles.'
    task :db_profiles => :environment do |t, args|
      Utility::ContentProfileDataLoader.new().report_current_population
    end

    desc 'Lists XML ContentProfiles.[false|true] false is content only entries.'
    task :xml_profiles, [:arg1] => :environment do |t, args|
      Utility::ContentProfileDataLoader.new().report_access_registry_xml_listing('true'.eql?(args[:arg1]) || false)
    end
  end

end
