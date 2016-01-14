class AddAssignedRolesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :assigned_roles, :string, limit: 4096
  end
end
