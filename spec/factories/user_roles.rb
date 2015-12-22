# == Schema Information
#
# Table name: user_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :user_role do
    name "MyString"
description "MyString"
  end

end
