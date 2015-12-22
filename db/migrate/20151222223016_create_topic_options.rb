class CreateTopicOptions < ActiveRecord::Migration
  def change
    create_table :topic_options do |t|
      t.references :topic_type, index: true, foreign_key: true
      t.references :topic_type_opt, index: true, foreign_key: true
    end
  end
end
