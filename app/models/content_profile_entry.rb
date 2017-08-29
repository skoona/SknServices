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
  has_and_belongs_to_many :content_profiles, inverse_of: :content_profile_entries, :join_table => :join_entries

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

  def self.option_selects
    options = []
    self.find_each do |cpes|
      options << [cpes.description, cpes.id, {'data-description': "#{cpes.content_type_description} / #{cpes.topic_type_description}"}]
    end
    options
  end

  def entry_contents
    opts = []
    content_value.collect do |v|
      opts << [v,0, {'data-description': content_type_description}]
    end
    opts
  end
  def entry_topics
    opts = []
    topic_value.collect do |v|
      opts << [v,0, {'data-description': topic_type_description}]
    end
    opts
  end

  def entry_info_with_username(userp)
    entry_info.merge({user_options: userp.user_options, username: userp.username, id: self.id})
  end
  def entry_info_with_selects(userp)
    entry_info.merge({content_selects: entry_contents, topic_selects: entry_topics,
                     user_options: userp.user_options, username: userp.username})
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
