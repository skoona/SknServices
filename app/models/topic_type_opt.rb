# == Schema Information
#
# Table name: topic_type_opts
#
#  id            :integer          not null, primary key
#  value         :string
#  description   :string
#  topic_type_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TopicTypeOpt < ActiveRecord::Base
  belongs_to :topic_type, inverse_of: :topic_type_opts

  validates_presence_of :value, :description
end
