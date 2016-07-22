##
# lib/tasks/profile_tools_task.rake
#
# Preloads the ContentProfile Tables
#


namespace :access_registry do

  namespace :admin do

    desc 'Resets test data in all Content Profile related Models.'
    task :refresh_content_profiles => :environment do
      Utility::ContentProfileTestDataLoader.new().refresh_content_profiles_data_model
    end

    desc 'Lists Database ContentProfiles.'
    task :db_profiles => :environment do |t, args|
      Utility::ContentProfileTestDataLoader.new().report_current_population
    end

    desc 'Lists XML ContentProfiles.[false|true] false is content only entries.'
    task :xml_profiles, [:arg1] => :environment do |t, args|
      Utility::ContentProfileTestDataLoader.new().report_access_registry_xml_listing('true'.eql?(args[:arg1]) || false)
    end
  end

end
