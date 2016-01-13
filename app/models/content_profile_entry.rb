# == Schema Information
#
# Table name: content_profile_entries
#
#  id            :integer          not null, primary key
#  topic_value   :string
#  content_value :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  description   :string
#

class ContentProfileEntry < ActiveRecord::Base
  has_and_belongs_to_many :content_types, inverse_of: :content_profile_entries, :join_table => :join_contents
  has_and_belongs_to_many :topic_types, inverse_of: :content_profile_entries, :join_table => :join_topics
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

  accepts_nested_attributes_for :content_types, :topic_types, allow_destroy: true, reject_if: lambda {|attributes| attributes['name'].blank?}

  validates_presence_of :topic_value, :description

  def self.cpe_options_selects
    self.all.map do |cpes|
      [cpes.description, cpes.id, {data_description: "#{cpes.content_type.name}:#{cpes.topic_type.name}"}]
    end
  end

  def content_type_name
    content_types.first.try(:name) || "not assigned"
  end
  def topic_type_name
    topic_types.first.try(:name) || "not assigned"
  end

  def entry_info
    {
      content_value: content_value,
      content_type: content_type_name,
      content_type_description: content_types.first.try(:description) || "not assigned",
      topic_value: topic_value,
      topic_type: topic_type_name,
      topic_type_description: topic_types.first.try(:description) || "not assigned",
      description: description
    }
  end
end
