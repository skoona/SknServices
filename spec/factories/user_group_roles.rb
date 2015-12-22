# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  group_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :user_group_role do
    name "MyString"
description "MyString"
group_type "MyString"
  end

end
