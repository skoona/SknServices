# == Schema Information
#
# Table name: user_group_roles_user_roles
#
#  id                 :integer          not null, primary key
#  user_group_role_id :integer
#  user_role_id       :integer
#

FactoryGirl.define do
  factory :user_group_roles_user_role do
    user_group_role nil
user_role nil
  end

end
