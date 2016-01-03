class AddUserOptionsAndRemoveLastLoginFromUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_options, :string
    remove_column :users, :last_login
  end
end
