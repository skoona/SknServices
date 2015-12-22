# == Schema Information
#
# Table name: topic_types
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :string
#  value_based_y_n :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TopicType < ActiveRecord::Base
  has_and_belongs_to_many :topic_type_opts, :join_table => :topic_option
  has_one  :content_profile_entry, inverse_of: :topic_type

  validates_presence_of :name, :description
end
