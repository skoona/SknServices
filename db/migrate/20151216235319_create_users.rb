class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :remember_token
      t.string :password_reset_token
      t.datetime :password_reset_date
      t.string :role_groups
      t.string :roles
      t.boolean :active, default: true
      t.string :file_access_token

      t.timestamps null: false
    end
    add_index :users, :username
    add_index :users, :remember_token
  end
end
