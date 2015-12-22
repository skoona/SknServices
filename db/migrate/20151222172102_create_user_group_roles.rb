class CreateUserGroupRoles < ActiveRecord::Migration
  def change
    create_table :user_group_roles do |t|
      t.string :name
      t.string :description
      t.string :group_type

      t.timestamps null: false
    end
    add_index :user_group_roles, :name, unique: true
  end
end
