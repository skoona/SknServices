class AddUserOptionsAndRemoveLastLoginFromUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_options, :string, limit: 4096
    remove_column :users, :last_login
  end
end
