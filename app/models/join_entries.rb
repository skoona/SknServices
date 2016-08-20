# == Schema Information
#
# Table name: join_entries
#
#  id                       :integer          not null, primary key
#  content_profile_id       :integer
#  content_profile_entry_id :integer
#

class JoinEntries < ApplicationRecord
  belongs_to :content_profile
  belongs_to :content_profile_entry
end
