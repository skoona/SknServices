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

FactoryBot.define do
  factory :content_profile do
    person_authentication_key { "MyString" }
    profile_type  { nil }
    authentication_provider { "MyString" }
    username      { "MyString" }
    display_name  { "MyString" }
    email         { "MyString" }
  end

end
