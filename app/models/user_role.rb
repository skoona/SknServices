# == Schema Information
#
# Table name: user_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserRole < ActiveRecord::Base
  has_and_belongs_to_many :user_group_roles

  validates_uniqueness_of :name
end
