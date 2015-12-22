class CreateContentProfileEntries < ActiveRecord::Migration
  def change
    create_table :content_profile_entries do |t|
      t.string :topic_value
      t.string :content_value
      t.references :content_type, index: true, foreign_key: true
      t.references :topic_type, index: true, foreign_key: true
      t.references :content_profile, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
