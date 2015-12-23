class AddAssignedRolesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :assigned_roles, :string
  end
end
