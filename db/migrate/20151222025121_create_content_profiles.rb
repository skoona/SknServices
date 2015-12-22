class CreateContentProfiles < ActiveRecord::Migration
  def change
    create_table :content_profiles do |t|
      t.string :person_authentication_key
      t.references :profile_type, index: true, foreign_key: true
      t.string :authentication_provider
      t.string :username
      t.string :display_name
      t.string :email

      t.timestamps null: false
    end
    add_index :content_profiles, :person_authentication_key, unique: true
  end
end
