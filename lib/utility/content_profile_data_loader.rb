##
# Creates initial data load for content profile
#
# http://guides.rubyonrails.org/form_helpers.html#building-complex-forms
#
#
  ##
  #
  # Content Profile Initialization
  #
  ##

module Utility
  class ContentProfileDataLoader

    def initialize
      Rails.logger.info "Clearing ContentProfile process tables"
    end


    # {UUID/AgencyOwner} => [
    #     PAK/ProfileType    {Commission/Agency/0034 => "CommRptID,CommCsvID,ExperRptID"},
    #                        {Notification/Account/99 => "AdvCancel,Cancel"},
    #                        {Operations/LicensedStates/USA => "21,30,34,45"}
    # ]                      ContentType/TopicType/TopicTypeOpts => ContentTypeOpts

    def create_content_types
      print "Start ContentTypes and ContentOptions: "

      ct  = [
          {name: "Commission",   description: "Monthly Commission Reports and Files", value_data_type: "Integer",
           content_type_opts: {
               "0" => {value: "68601", description: "Imageright Commision Document Type ID" },
               "1" => {value: "68602", description: "Imageright Commision CSV Document Type ID" },
               "2" => {value: "68603", description: "Imageright Agency Experience Document Type ID" }}
          },
          {name: "Notification", description: "Email Notification of Related Events", value_data_type: "String",
           content_type_opts: {
               "0" => {value: "AdvCancel", description: "Advance Cancel" },
               "1" => {value: "FutCancel", description: "Future Cancel" },
               "2" => {value: "Cancel",    description: "Cancel" }}
          },
          {name: "Operations",   description: "Business Operational Metric",          value_data_type: "Integer",
           content_type_opts: {
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

    def create_topic_types
      Rails.logger.info "Defining TopicTypes and TopicOptions"

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

      Rails.logger.info "#{self.class.name}.#{__method__}() Created #{t_types.length} TopicType sets."

      t_types
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end

    def create_profile_types
      pt  = [
          {name: "AgencyPrimary",   description: "Agency Super User"},
          {name: "AgencySecondary", description: "Limited User"},
          {name: "EmployeePrimary",   description: "BMI Admin User"},
          {name: "EmployeeSecondary", description: "BMI Limited User"}
      ]

      ProfileType.destroy_all
      pt_types = []
      pt_types = ProfileType.create!(pt)

      Rails.logger.info "#{self.class.name}.#{__method__}() Created #{pt_types.length} ProfileType records."

      pt_types
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end


    ##
    # Make Associations
    def create_content_profile_entries(choices_hash={})
      choices = {
        content_choices: {
                    "Agency" => "Commission",
                   "Account" => "Notification",
            "LicensedStates" => "Operations"
        },
        topic_choices: {
                    "Agency" => "0034",
                   "Account" => "Agent",
            "LicensedStates" => "USA"
        }
      }

      cpe = [
        {topic_value: "Agency",     content_value: [], description: 'Determine which agency documents can be seen'},
        {topic_value: "Account",    content_value: [], description: 'Determine which accounts will have notification sent'},
        {topic_value: "LicensedStates", content_value: [], description: 'Determine which States agent may operate in.'}
      ]

      cpe_recs_ids = cpe.map do |item|
          topic_rec = tt_recs.detect {|t| t.name.eql?(item[:topic_value])}
          content_rec = ct_recs.detect {|t| t.name.eql?(human_content_choice[item[:topic_value]])}
          rec = ContentProfileEntry.create!(item)
          rec.content_value = content_rec.content_type_opts.map {|v| v.value}.uniq
          rec.content_type=content_rec
          rec.topic_type=topic_rec
          rec.topic_value=human_topic_choice[item[:topic_value]]
          rec.save!
          rec.id
      end
      Rails.logger.info "#{self.class.name}.#{__method__}() Created #{pt_types.length} ContentProfileEntry records."

      pt_types
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end


    def create_content_profile
      ContentProfile.destroy_all
      pt_rec = pt_recs.detect {|r| r.name.eql?("AgencyPrimary")}
      cp_types  = ContentProfile.create({person_authentication_key: urecs[3].person_authenticated_key,
              authentication_provider: "BCrypt",
              username: urecs[3].username,
              display_name: urecs[3].display_name,
              email: urecs[3].email,
              profile_type_id: pt_rec.id}
      )
      cp.content_profile_entry_ids=cpe_recs_ids

      Rails.logger.info "#{self.class.name}.#{__method__}() Created #{cp_types.length} ContentProfile records."

      cp_types
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end

  end # ContentDataLoader
end # Utility