# == Schema Information
#
# Table name: profile_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :profile_type do
    name        { "MyString" }
    description { "MyString" }
  end

end
