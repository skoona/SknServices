# == Schema Information
#
# Table name: content_types
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :string(255)
#  value_data_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :content_type do
    name "MyString"
description "MyString"
value_data_type "MyString"
  end

end
