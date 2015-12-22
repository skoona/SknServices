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

FactoryGirl.define do
  factory :content_profile do
    person_authentication_key "MyString"
profile_type nil
authentication_provider "MyString"
username "MyString"
display_name "MyString"
email "MyString"
  end

end
