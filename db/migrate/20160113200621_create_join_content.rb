class CreateJoinContent < ActiveRecord::Migration
  def change
    change_table :content_profile_entries do |t|
      t.remove_references :content_type
    end
    create_table :join_contents do |t|
      t.references :content_profile_entry, index: true, foreign_key: true
      t.references :content_type, index: true, foreign_key: true
    end
  end
end
