# == Schema Information
#
# Table name: content_profiles
#
#  id                        :integer          not null, primary key
#  person_authentication_key :string
#  profile_type_id           :integer
#  authentication_provider   :string
#  username                  :string
#  display_name              :string
#  email                     :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ContentProfile < ActiveRecord::Base
  belongs_to :profile_type
  has_many :content_profile_entries, inverse_of: :content_profile

  accepts_nested_attributes_for :content_profile_entries, :profile_type, allow_destroy: false

  validates :person_authentication_key, uniqueness: true, on: [:create, :update]

  def self.cp_options_selects
    self.all.map do |cps|
      [cps.username, cps.id, {data_description: "#{cps.display_name} <#{cps.email}>"}]
    end
  end

  def profile_type_name
    profile_type.name
  end
  def profile_type_description
    profile_type.description
  end

  # options_for_select(tt_instance.options_selects, selected)  -- single selection
  def cpe_options_selects
    content_profile_entries.map do |cpe|
      [cpe.description, cpe.id, {data_description: "#{cpe.content_type.name}:#{cpe.topic_type.name}"} ]
    end
  end

  def profile
    Utility::ContentProfileBean.new({
      entries: content_profile_entries.map(&:entry_info) || [],
      pak: person_authentication_key,
      profile_type: profile_type.name,
      profile_type_description: profile_type.description,
      provider: authentication_provider,
      username: username,
      display_name: display_name,
      email: email
    })
  end
end
