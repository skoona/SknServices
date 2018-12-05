# == Schema Information
#
# Table name: topic_type_opts
#
#  id            :integer          not null, primary key
#  value         :string(255)
#  description   :string(255)
#  type_name     :string(255)
#  topic_type_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :topic_type_opt do
    value       { "MyString" }
    description { "MyString" }
    topic_type  { nil }
  end

end
