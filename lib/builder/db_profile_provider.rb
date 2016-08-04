##
# lib/builder/db_profile_provider.rb
#
# ContentProfile from DB
#
# Storage thru Factory

module Builder
  class DBProfileProvider < ::Factory::ProvidersBase

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


    ##
    # Available List Methods
    ##

    # returns an array of names
    # [["Developer", 1, {:"data-description"=>"Open Source Independent Consultancy"}]]
    def profile_type_choices
      ProfileType.option_selects
    end

    # returns an array of names
    # [["Determine which States branches are authorized to operate in.", 3, {:"data-description"=>"Branch Operations for a specific branch / Branch Operations for a specific branch"}]]
    def content_entry_choices
      ContentProfileEntry.option_selects
    end

    # returns an array of names
    # [["LicensedStates", 3, {:"data-description"=>"Business Operational Metric"}]]
    def content_type_choices
      ContentType.option_selects
    end

    # [["Branch", 1, {:"data-description"=>"Branch Actions for a specific branch"}]]
    def topic_type_choices
      TopicType.option_selects
    end

    ##
    # Selection Methods
    ##

    # Returns when clean is true
    # [ {:type=>{"name"=>"LicensedStates", "description"=>"Business Operational Metric", "value_data_type"=>"Integer"},
    #    :opts=>[{"value"=>"23", "description"=>"Illinois", "type_name"=>"LicensedStates"},
    #            {"value"=>"9", "description"=>"Ohio", "type_name"=>"LicensedStates"},
    #            {"value"=>"21", "description"=>"Michigan", "type_name"=>"LicensedStates"}
    #           ]
    #   }
    # ]
    def selections_for_content_type(type, clean=false)
      choices = ContentType.where(name: type).includes(:content_type_opts).map do |recs|
        {type: recs.attributes,
         opts: recs.content_type_opts.map(&:attributes)}
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    # Returns when clean is true
    # [ {:type=>{"name"=>"Branch", "description"=>"Branch Actions for a specific branch", "value_based_y_n"=>"N"},
    #    :opts=>[{"value"=>"0034", "description"=>"South Branch Number", "type_name"=>"Branch"},
    #            {"value"=>"0037", "description"=>"North Branch Number", "type_name"=>"Branch"},
    #            {"value"=>"0040", "description"=>"West Branch Number", "type_name"=>"Branch"}
    #          ]
    #   }
    # ]
    def selections_for_topic_type(type, clean=false)
      choices = TopicType.where(name: type).includes(:topic_type_opts).map do |recs|
        {type: recs.attributes,
         opts: recs.topic_type_opts.map(&:attributes)}
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    # [{:type=>
    #       {"topic_value"=>["0040", "0037", "0034"],
    #        "topic_type"=>"Branch",
    #        "topic_type_description"=>"Branch Actions for a specific branch",
    #        "content_value"=>["*.log", "*.csv", "*.pdf"],
    #        "content_type"=>"Commission",
    #        "content_type_description"=>"Branch Actions for a specific branch",
    #        "description"=>"Determine which branch documents can be seen"},
    #   :opts=>[] }
    # ]
    def selections_for_content_profile_entry(content_type, clean=false)
      choices = ContentProfileEntry.where(content_type: content_type).map do |recs|
        {type: recs.attributes, opts: []}
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    # [64] pry(main)> choices = dpp.selections_for_content_type("LicensedStates")
    #
    # [ {:type=>{"name"=>"LicensedStates", "description"=>"Business Operational Metric", "value_data_type"=>"Integer"},
    #    :opts=>[{"value"=>"23", "description"=>"Illinois", "type_name"=>"LicensedStates"},
    #            {"value"=>"9", "description"=>"Ohio", "type_name"=>"LicensedStates"},
    #            {"value"=>"21", "description"=>"Michigan", "type_name"=>"LicensedStates"}]}]
    #
    # [65] pry(main)> dpp.selections_choose_for(["9","21"], choices)
    #
    # [ {:type=>{"name"=>"LicensedStates", "description"=>"Business Operational Metric", "value_data_type"=>"Integer"},
    #    :opts=>[{"value"=>"9", "description"=>"Ohio", "type_name"=>"LicensedStates"},
    #            {"value"=>"21", "description"=>"Michigan", "type_name"=>"LicensedStates"}]}]
    #
    def selections_choose_for(a_choices, ah_type_values, clean=true)
      choices = []
      ah_type_values.each do |atv|
        chosen = atv[:opts].select {|opt| opt["value"].in?(a_choices)}.flatten
        choices << {type: atv[:type], opts: chosen} if chosen.present?
      end
      clean ? remove_dates_and_ids_from_choices(choices) : choices
    end

    ##
    # Creation Methods
    ##

    #  {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
    #   content_type_opts_attributes: {
    #     "0" => {value: "*.pdf", type_name: "Commission", description: "Document store Commision Document Type ID" },
    #     "1" => {value: "*.csv", type_name: "Commission", description: "Document store Commision CSV Document Type ID" },
    #     "2" => {value: "*.log", type_name: "Commission", description: "Document store Branch Experience Document Type ID"} }
    #  }
    ##
    # Returns the created record
    def create_content_type_and_options(choices)
      package = choices[:type]
      if choices.key?(:opts)
        package[:content_type_opts_attributes] = {}
        choices[:opts].each_with_index do |opt, idx|
          package[:content_type_opts_attributes].store(idx.to_s, opt)
        end
      elsif choices.key?(:content_type_opts_attributes)
        package[:content_type_opts_attributes] = choices[:content_type_opts_attributes]
      else
        raise ArgumentError, "Unknown Format for ContentType: #{choices["name"] || choices[:name] }"
      end

      ContentType.create!(package)
    end

    #  {name: "Branch",  description: "Branch Actions for a specific branch",  value_based_y_n: "N",
    #   topic_type_opts_attributes: {
    #      "0" => {value: "0034", type_name: "Branch", description: "South Branch Number"},
    #      "1" => {value: "0037", type_name: "Branch", description: "North Branch Number"},
    #      "2" => {value: "0040", type_name: "Branch", description: "West Branch Number"} }
    #  }
    # Returns the created record
    def create_topic_type_and_options(choices)
      package = choices[:type]
      # check format :type or :content_type_opts_attributes
      if choices.key?(:opts)
        package[:topic_type_opts_attributes] = {}
        choices[:opts].each_with_index do |opt, idx|
          package[:topic_type_opts_attributes].store(idx.to_s, opt)
        end
      elsif choices.key?(:topic_type_opts_attributes)
        package[:topic_type_opts_attributes] = choices[:topic_type_opts_attributes]
      else
        raise ArgumentError, "Unknown Format for TopicType: #{choices["name"] || choices[:name] }"
      end

      TopicType.create!(package)
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
         person_authentication_key: user_p.id,
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

    def remove_content_profile_entry_from(profile_obj, profile_entry_obj)
      profile_obj.content_profile_entries.destroy(profile_entry_obj)
      profile_obj.save!
      profile_obj.content_profile_entries.reload
      profile_obj
    end


    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key)
    end

  protected
    ##
    # ContentProfile
    ##

    def remove_dates_and_ids_from_choices(choices)
      targets = ["id", "created_at", "updated_at", "content_type_id", "topic_type_id"]
      choices.each do |choice|
        choice[:type].delete_if {|k,v| k.in?(targets) }
        choice[:opts].each {|opt| opt.delete_if {|k,v| k.in?(targets)}}
      end
      choices
    end

    # Retrieves users content profile in ResultBean
    def collect_content_profile_bean(user_profile)
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
      update_storage_object(user_profile.person_authenticated_key, results) unless ctxp.nil?

      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
      
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      delete_storage_object(user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end

  end
end