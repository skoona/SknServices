# == Schema Information
#
# Table name: topic_types
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :string
#  value_based_y_n :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :topic_type do
    name "MyString"
description "MyString"
value_based_y_n "MyString"
  end

end
