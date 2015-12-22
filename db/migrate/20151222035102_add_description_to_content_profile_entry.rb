class AddDescriptionToContentProfileEntry < ActiveRecord::Migration
  def change
    add_column :content_profile_entries, :description, :string
  end
end
