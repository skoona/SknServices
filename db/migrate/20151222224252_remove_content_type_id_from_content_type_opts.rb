class RemoveContentTypeIdFromContentTypeOpts < ActiveRecord::Migration
  def change
    remove_reference :content_type_opts, :content_type, index: true, foreign_key: true
  end
end
