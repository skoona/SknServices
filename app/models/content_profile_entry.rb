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

class ContentProfileEntry < ActiveRecord::Base
  belongs_to :content_type
  belongs_to :topic_type
  belongs_to :content_profile, inverse_of: :content_profile_entries

  serialize :content_value, Array

  accepts_nested_attributes_for :content_type, :topic_type, allow_destroy: false

  validates_presence_of :topic_value, :description

  def self.cpe_options_selects
    self.all.map do |cpes|
      [cpes.description, cpes.id, {data_description: "#{cpes.content_type.name}:#{cpes.topic_type.name}"}]
    end
  end

  def content_type_name
    content_type.name
  end
  def topic_type_name
    topic_type.name
  end

  def entry_info
    {
      content_value: content_value,
      content_type: content_type.name,
      content_type_description: content_type.description,
      topic_value: topic_value,
      topic_type: topic_type.name,
      topic_type_description: topic_type.description,
      description: description
    }
  end
end
