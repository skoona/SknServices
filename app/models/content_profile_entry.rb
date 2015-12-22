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

  validates_presence_of :topic_value, :description

  def content_value_name
    content_type.name
  end
  def topic_type_name
    topic_type.name
  end

end
