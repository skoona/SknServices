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

class ContentProfileEntry < ActiveRecord::Base
  has_and_belongs_to_many :content_profiles, inverse_of: :content_profile_entries, :join_table => :content_profiles_entries

  before_create { |record|
    record.topic_value = [record.topic_value].flatten unless record.topic_value.is_a?(Array)
    record.content_value = [record.content_value].flatten unless record.content_value.is_a?(Array)
  }

  before_save { |record|
    record.topic_value = [record.topic_value].flatten unless record.topic_value.is_a?(Array)
    record.content_value = [record.content_value].flatten unless record.content_value.is_a?(Array)
  }


  serialize :content_value, Array
  serialize :topic_value, Array

  validates_presence_of :description, :content_type, :topic_type

  def entry_info_with_username(userp)
    entry_info.merge({user_options: userp.user_options, username: userp.username, id: self.id})
  end

  def entry_info
    {
      content_value: content_value,
      content_type: content_type,
      content_type_description: content_type_description,
      topic_value: topic_value,
      topic_type: topic_type,
      topic_type_description: topic_type_description,
      description: description,
      last_update: updated_at.strftime("%Y-%m-%d %I:%M:%S %p")
    }
  end
end
