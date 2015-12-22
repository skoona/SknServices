class CreateContentOptions < ActiveRecord::Migration
  def change
    create_table :content_options do |t|
      t.references :content_type, index: true, foreign_key: true
      t.references :content_type_opt, index: true, foreign_key: true
    end
  end
end
