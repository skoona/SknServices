# == Schema Information
#
# Table name: join_contents
#
#  id                       :integer          not null, primary key
#  content_profile_entry_id :integer
#  content_type_id          :integer
#

class JoinContent < ActiveRecord::Base
  belongs_to :content_profile_entry
  belongs_to :content_type
end
