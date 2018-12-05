# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  group_type  :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :user_group_role do
    name        { "MyString" }
    description { "MyString" }
    group_type  { "MyString" }
  end

end
