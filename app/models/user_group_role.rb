# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  group_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserGroupRole < ActiveRecord::Base
  has_and_belongs_to_many :user_roles, join_table: :user_group_roles_user_roles

  validates_uniqueness_of :name

  def self.list_user_roles(group_role_name)
    rec = find_by(name: group_role_name)
    rec.nil?  ? [] : rec.user_role_names
  end
  def user_role_names
    self.user_roles.map(&:name)
  end
end
