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

  validates :person_authentication_key, uniqueness: true, on: [:create, :update]

  def profile_type_name
    profile_type.name
  end
  def profile_type_description
    profile_type.description
  end

  def profile
    Secure::UserContentProfile.new({
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
