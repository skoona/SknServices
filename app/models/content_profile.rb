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
end
