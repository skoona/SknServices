# == Schema Information
#
# Table name: profile_types
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProfileType < ActiveRecord::Base
  has_one :content_profile

  validates_presence_of :name, :description
end
