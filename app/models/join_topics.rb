# == Schema Information
#
# Table name: join_topics
#
#  id                       :integer          not null, primary key
#  content_profile_entry_id :integer
#  topic_type_id            :integer
#

class JoinTopics < ActiveRecord::Base
  belongs_to :content_profile_entry
  belongs_to :topic_type
end
