# == Schema Information
#
# Table name: content_profiles
#
#  id                        :integer          not null, primary key
#  person_authentication_key :string(255)
#  profile_type_id           :integer
#  authentication_provider   :string(255)
#  username                  :string(255)
#  display_name              :string(255)
#  email                     :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ContentProfile < ApplicationRecord
  belongs_to :profile_type
  has_and_belongs_to_many :content_profile_entries, inverse_of: :content_profiles, :join_table => :join_entries

  accepts_nested_attributes_for :content_profile_entries, :profile_type, allow_destroy: true, reject_if: lambda {|attributes| attributes['description'].blank?}

  validates :person_authentication_key, uniqueness: true, on: [:create, :update]

  def self.option_selects
    options
    self.find_each do |cps|
      options << [cps.username, cps.id, {'data-description': "#{cps.display_name} <#{cps.email}>"}]
    end
    options
  end

  def profile_type_name
    profile_type.try(:name)
  end
  def profile_type_description
    profile_type.try(:description)
  end

  # options_for_select(tt_instance.option_selects, selected)  -- single selection
  def option_selects
    content_profile_entries.map do |cpe|
      [cpe.description, cpe.id, {'data-description': "#{cpe.content_type}:#{cpe.topic_type}"} ]
    end
  end

  def entry_info_with_username(userp)
    {
        pak: person_authentication_key,
        profile_type: profile_type_name,
        profile_type_description: profile_type_description,
        provider: authentication_provider,
        username: username,
        display_name: display_name,
        email: email,
        assigned_group: userp.assigned_groups,
        user_options: userp.user_options,
        entries: content_profile_entries.collect {|cpe| cpe.entry_info_with_username(userp)}
    }
  end

  def entry_info_with_selects(userp)
    {
        pak: person_authentication_key,
        profile_type: profile_type_name,
        profile_type_description: profile_type_description,
        provider: authentication_provider,
        username: username,
        display_name: display_name,
        email: email,
        assigned_group: userp.assigned_groups,
        user_options: userp.user_options,
        entries: content_profile_entries.collect {|cpe| cpe.entry_info_with_selects(userp)}
    }
  end

  def entry_info
    {
        pak: person_authentication_key,
        profile_type: profile_type_name,
        profile_type_description: profile_type_description,
        provider: authentication_provider,
        username: username,
        display_name: display_name,
        email: email,
        entries: content_profile_entries.collect(&:entry_info)
    }
  end
end
