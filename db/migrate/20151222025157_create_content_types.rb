class CreateContentTypes < ActiveRecord::Migration
  def change
    create_table :content_types do |t|
      t.string :name
      t.string :description
      t.string :value_data_type

      t.timestamps null: false
    end
  end
end
