# == Schema Information
#
# Table name: content_profile_entries
#
#  id                       :integer          not null, primary key
#  topic_value              :string
#  topic_type               :string(255)
#  topic_type_description   :string(255)
#  content_value            :string
#  content_type             :string(255)
#  content_type_description :string(255)
#  description              :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :content_profile_entry do
    topic_value   { "MyString" }
    content_value { "MyString" }
    content_type  { nil }
    topic_type    { nil }
    content_profile { nil }
  end

end
