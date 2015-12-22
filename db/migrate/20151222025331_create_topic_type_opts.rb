class CreateTopicTypeOpts < ActiveRecord::Migration
  def change
    create_table :topic_type_opts do |t|
      t.string :value
      t.string :description
      t.references :topic_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
