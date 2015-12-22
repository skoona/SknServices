class CreateTopicTypes < ActiveRecord::Migration
  def change
    create_table :topic_types do |t|
      t.string :name
      t.string :description
      t.string :value_based_y_n

      t.timestamps null: false
    end
  end
end
