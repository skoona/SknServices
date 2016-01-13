class CreateJoinEntry < ActiveRecord::Migration
  def change
    change_table :content_profile_entries do |t|
      t.remove_references :content_profile
    end
    create_table :join_entries do |t|
      t.references :content_profile, index: true, foreign_key: true
      t.references :content_profile_entry, index: true, foreign_key: true
    end
  end
end
