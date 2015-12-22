# == Schema Information
#
# Table name: content_profile_entries
#
#  id                 :integer          not null, primary key
#  topic_value        :string
#  content_value      :string
#  content_type_id    :integer
#  topic_type_id      :integer
#  content_profile_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :string
#

FactoryGirl.define do
  factory :content_profile_entry do
    topic_value "MyString"
content_value "MyString"
content_type nil
topic_type nil
content_profile nil
  end

end
