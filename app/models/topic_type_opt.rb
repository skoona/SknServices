# == Schema Information
#
# Table name: topic_type_opts
#
#  id          :integer          not null, primary key
#  value       :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TopicTypeOpt < ActiveRecord::Base
  has_and_belongs_to_many :topic_types, :join_table => :topic_option

  validates_presence_of :value, :description
end
