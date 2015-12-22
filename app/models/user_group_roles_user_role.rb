# == Schema Information
#
# Table name: user_group_roles_user_roles
#
#  id                 :integer          not null, primary key
#  user_group_role_id :integer
#  user_role_id       :integer
#

class UserGroupRolesUserRole < ActiveRecord::Base
  belongs_to :user_group_role
  belongs_to :user_role
end
