class AddPersonAuthenticatedKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :person_authenticated_key, :string
    add_index :users, :person_authenticated_key, unique: true
  end
end
