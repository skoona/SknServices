# == Schema Information
#
# Table name: topic_options
#
#  id                :integer          not null, primary key
#  topic_type_id     :integer
#  topic_type_opt_id :integer
#

class TopicOption < ActiveRecord::Base
  belongs_to :topic_type
  belongs_to :topic_type_opt
end
