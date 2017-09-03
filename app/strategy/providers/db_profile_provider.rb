##
# File: <root>/app/strategy/providers/db_profile_provider.rb
#
# ContentProfile from DB
#
# Storage thru Registry

module Providers
  class DBProfileProvider < ProvidersBase

    PROVIDER_PREFIX = self.name

    def initialize(params={})
      super(params)
    end

    def self.provider_type
      PROVIDER_PREFIX
    end

    def provider_type
      PROVIDER_PREFIX
    end

    ##
    # Retrieve Profiles
    ##
    def content_profile_for_user(usr_profile, beaned=false)
      hsh = collect_content_profile_bean(usr_profile)
      beaned ? Utility::ContentProfileBean.new(hsh) : hsh
    end

    def content_profile_for_runtime(user_profile, available_resource_catalog=true)
      profile = ContentProfile.find_by(person_authentication_key: user_profile.person_authenticated_key).try(:entry_info)
      cprofile = condense_profile_entries(profile, user_profile, available_resource_catalog)
      Rails.logger.debug "#{self.class.name}.#{__method__}() ContentProfile: #{cprofile.present? ? 'Found' : 'Not Found'}"
      cprofile
    end

    def select_option_values_for_content_type(name)
      ContentType.option_selects_by_type(name).first.last[:data][:opts].collect {|c| c.first }
    end
    def select_options_by_topic_name(name)
      TopicTypeOpt.option_selects(name).collect {|tt| ["#{tt.first} | #{tt.last[:data][:description]}", tt.first] }
    end
    def select_option_values_for_topic_type(name)
      TopicTypeOpt.where(type_name: name).pluck(:value)
    end

    def profile_type_select_options_with_description
      ProfileType.option_selects_with_desc
    end
    def content_type_select_options_with_description
      ContentType.option_selects_with_desc
    end
    def topic_type_select_options_with_description
      TopicType.option_selects_with_desc
    end
    def content_type_opts_select_options_with_description(name)
      ContentTypeOpt.option_selects_with_desc(name)
    end
    def topic_type_opts_select_options_with_description(name)
      TopicTypeOpt.option_selects_with_desc(name)
    end
    def member_topic_type_opts_select_options_with_description(name)
      TopicTypeOpt.member_option_selects_with_desc(name)
    end
    ##
    # Creation Methods
    ##

    def parse_member_update_params(params)
      # c_name, [c_value], t_type, [t_value]
      choices = []
      user_options_list = []

      activity = params['member'].delete('activity') if params.dig('member', 'activity')
      if activity
        content_values = ContentTypeOpt.where(type_name: 'Activity').pluck(:value)
        activity['partners'].each do |a|
          if content_values.size < 2
            choices << [ 'Activity', content_values, 'Partner', [a] ]
          else
            content_values.each {|x| choices << [ 'Activity', [x], 'Partner', [a] ] }
          end
        end
      end

      filedownload = params['member'].delete('filedownload') if params.dig('member', 'filedownload')
      if filedownload
        content_values = ContentTypeOpt.where(type_name: 'FileDownload').pluck(:value).flatten
        filedownload['usergroups'].each do |a|
          if content_values.size < 2
            choices << ['FileDownload', content_values, 'UserGroups', [a]]
          else
            content_values.each {|x| choices << ['FileDownload', [x], 'UserGroups', [a]] }
          end
        end
      end


      params['member'] && params['member'].each_pair do |cv,pkg|
        user_options_list << cv
        pkg.each_pair do |k,v|
          case k
            when 'Commission', 'Experience'
              vals = ContentTypeOpt.where(type_name: k).pluck(:value)
              if vals.size < 2
                choices << [ k, vals , 'Branch', [cv] ]
              else
                vals.each {|x| choices << [ k, [x] , 'Branch', [cv] ] }
              end
            when 'Notification', 'LicensedStates'
              if v.size < 2
                choices << [ k, v , 'Branch', [cv] ]
              else
                v.each {|x| choices << [ k, [x], 'Branch', [cv] ] }
              end
            else
              puts "IGNORED: #{k} => #{v}"
          end
        end
      end

      if choices.empty?
        [[]]
      else
        choices.unshift(user_options_list)
      end

    end

    # [ user_options_list,
    #   [ c_name, [c_value], t_type, [t_value] ]
    # ]
    # Expects ?_values to be max-size of 1
    def apply_member_updates(pak, choices)
      rc = false
      content_profile = ContentProfile.find_by(person_authentication_key: pak)
      return false unless content_profile

      delete_storage_object(pak)

      user_options_list = choices.shift
      if choices.empty?
        content_profile.content_profile_entries.clear
        return true    # early exit if nothing to do
      end

      ActiveRecord::Base.transaction do

        cpes = []
        rc = false
        choices.each do |choice|
          things = []
          things = ContentProfileEntry.where(topic_type: choice[2], content_type: choice[0]).select do |s|
            choice[3].eql?(s.topic_value) and choice[1].eql?(s.content_value)
          end.compact

          if things.present?
            cpes << things.first    # only need one
          else
            cdesc = ContentType.find_by(name: choice.first).try(:description)
            tdesc = TopicType.find_by(name: choice[2]).try(:description)
            desc = "#{cdesc} for #{choice[2]}"
            cpes << ContentProfileEntry.create!({
                description: desc,
                content_value: choice[1],
                content_type: choice[0],
                content_type_description: cdesc,
                topic_value: choice[3],
                topic_type: choice[2],
                topic_type_description: tdesc
            })
          end
        end

        rc = content_profile.content_profile_entries = cpes.flatten
        if rc.present? and !!defined?(user_options_list)
          user_profile = get_page_user(content_profile.username)
          user_profile.update_user_options!( user_options_list )
        end

        true
      end # end transaction

      Rails.logger.debug "#{self.class.name}.#{__method__}() saving: #{choices.size} entries returned #{rc.present?}"

      rc.present?
    end


    #   "id"=>"profile entry id",
    #   "pak"=>"72930134e6222904010dd4d6fb5f1887",
    #   "username"=>"bptester",
    #   "description"=>"Samples",
    #   "topic_type_id"=>"1",
    #   "topic_type_value"=>["1"],
    #   "content_type_id"=>"3",
    #   "content_type_value"=>["9", "8", "7"],
    #   "button"=>"content-entry-modal"
    # }
    def create_content_profile_entry_by_ids(params)
      tchoices = TopicType.where(id: params['topic_type_id'].to_i).includes(:topic_type_opts).map do |rec|
        {type: rec.attributes,
         opts: rec.topic_type_opts.where(id: params['topic_type_value'].collect(&:to_i)).map(&:attributes)}
      end
      cchoices = ContentType.where(id: params['content_type_id'].to_i).includes(:content_type_opts).map do |rec|
        {type: rec.attributes,
         opts: rec.content_type_opts.where(id: params['content_type_value'].collect(&:to_i)).map(&:attributes)}
      end
      cpe = create_content_profile_entry_for(params['description'], tchoices, cchoices)
      assign_content_profile_entry_to(ContentProfile.where(person_authentication_key: params['pak']).first, cpe)
    end

    # {topic_value: [],  content_value: [], content_type: "LicensedStates", topic_type: "Branch",
    #  topic_type_description: "", content_type_description: "",
    #  description: 'Determine which States branches are authorized to operate in.'
    # }
    #
    # => [{:type=>{"name"=>"LicensedStates", "description"=>"Business Operational Metric", "value_data_type"=>"Integer"},
    #      :opts=>[{"value"=>"9", "description"=>"Ohio", "type_name"=>"LicensedStates"},
    #              {"value"=>"21", "description"=>"Michigan", "type_name"=>"LicensedStates"}]
    #     }]
    # topic_choice,content_choice expect one hash; apply first if needed
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

    def update_content_profile_for(pak, profile_type_id )
      cp = ContentProfile.where(person_authentication_key: pak).first.update!(profile_type_id: profile_type_id)
      delete_storage_object(pak)
      cp
    end

    def destroy_content_profile_by_pak(pak)
      cb = ContentProfile.where(person_authentication_key: pak).first.destroy!
      delete_storage_object(pak)
      cb
    end

    def destroy_content_profile_entry_with_pak_and_id(pak, cpe_id)
      cp = ContentProfile.where(person_authentication_key: pak).first
      cpe = ContentProfileEntry.find(cpe_id)
      remove_content_profile_entry_from(cp, cpe)
    end

    def assign_content_profile_entry_to(profile_obj, profile_entry_obj)
      profile_obj.content_profile_entries << profile_entry_obj
      profile_obj.save!
      profile_obj.content_profile_entries.reload
      delete_storage_object(profile_obj.person_authentication_key)
      profile_obj
    end


  protected
    ##
    # ContentProfile
    ##



    def condense_profile_entries(profile, user_profile, avail = true)
      collection = []
      return nil unless profile.present?

      profile[:entries].each do |cpe|

        cpe.merge!({
                       id: 'content',
                       username: user_profile.username,
                       user_options: user_profile.user_options,
                       pak: user_profile.person_authenticated_key
                   }) # fixup for accessible list

        worker = collection.detect do |x|
          cpe[:topic_type] == x[:topic_type] &&
              cpe[:content_type] == x[:content_type]
        end

        if worker
          worker[:content_value] << cpe[:content_value].first unless worker[:content_value].include?(cpe[:content_value].first)
          worker[:topic_value] << cpe[:topic_value].first unless worker[:topic_value].include?(cpe[:topic_value].first)
        else
          collection << cpe
        end
      end

      profile[:display_groups] = append_available_content_for_collection!(collection) if avail

      profile
    end

    # get catalog and swap state numbers for their real names
    def append_available_content_for_collection!(collection)
      collection.each do |cpe|
        cpe[:content] = adapter_for_content_profile_entry(cpe).preload_available_content_list(cpe)
        if cpe[:content].present?
          cpe[:content].each do |item|
            if cpe[:content_type].include?('LicensedStates')
              item[:filename] = long_state_name_from_number(item[:filename]).to_s
            end
          end
        end
      end
      collection
    end


    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key)
    end

    def remove_content_profile_entry_from(profile_obj, profile_entry_obj)
      profile_obj.content_profile_entries.destroy(profile_entry_obj)
      profile_obj.save!
      profile_obj.content_profile_entries.reload
      delete_storage_object(profile_obj.person_authentication_key)
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

    def remove_dates_from_choices(choices)
      targets = ["created_at", "updated_at"]
      choices.each do |choice|
        choice[:type].delete_if {|k,v| k.in?(targets) }
        choice[:opts].each {|opt| opt.delete_if {|k,v| k.in?(targets)}}
      end
      choices
    end

    # Retrieves users content profile in ResultBean
    def collect_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      cpobj = get_existing_profile(user_profile)
      return  cpobj if cpobj

      results = {}
      ctxp = ContentProfile.includes(:content_profile_entries).find_by( person_authentication_key: user_profile.person_authenticated_key)

      unless ctxp.nil?
        results =  ctxp.entry_info_with_username(user_profile).merge({ success: true })
      else
        results = {
            success: false,
            message: "No content profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      update_storage_object(user_profile.person_authenticated_key, results) unless results[:entries].empty?

      Rails.logger.debug("#{self.class.name}.#{__method__}() returns: #{results.to_hash.keys}")
      results
      
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      delete_storage_object(user_profile.person_authenticated_key) if user_profile.present?
      {
        success: false,
        message: e.message,
        username: 'unknown',
        entries:[]
      }
    end

  end
end