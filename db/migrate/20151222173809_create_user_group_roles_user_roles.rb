class CreateUserGroupRolesUserRoles < ActiveRecord::Migration
  def change
    create_table :user_group_roles_user_roles do |t|
      t.references :user_group_role, index: true, foreign_key: true
      t.references :user_role, index: true, foreign_key: true
    end
  end
end
