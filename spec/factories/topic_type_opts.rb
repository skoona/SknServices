# == Schema Information
#
# Table name: topic_type_opts
#
#  id          :integer          not null, primary key
#  value       :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :topic_type_opt do
    value "MyString"
description "MyString"
topic_type nil
  end

end
