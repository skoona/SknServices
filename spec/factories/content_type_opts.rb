# == Schema Information
#
# Table name: content_type_opts
#
#  id          :integer          not null, primary key
#  value       :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :content_type_opt do
    value "MyString"
description "MyString"
content_type nil
  end

end
