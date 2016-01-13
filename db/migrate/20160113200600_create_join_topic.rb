class CreateJoinTopic < ActiveRecord::Migration
  def change
    change_table :content_profile_entries do |t|
      t.remove_references :topic_type
    end
    create_table :join_topics do |t|
      t.references :content_profile_entry, index: true, foreign_key: true
      t.references :topic_type, index: true, foreign_key: true
    end
  end
end
