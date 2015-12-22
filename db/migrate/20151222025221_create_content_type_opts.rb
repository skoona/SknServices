class CreateContentTypeOpts < ActiveRecord::Migration
  def change
    create_table :content_type_opts do |t|
      t.string :value
      t.string :description
      t.references :content_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
