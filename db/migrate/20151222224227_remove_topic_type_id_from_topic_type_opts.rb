class RemoveTopicTypeIdFromTopicTypeOpts < ActiveRecord::Migration
  def change
    remove_reference :topic_type_opts, :topic_type, index: true, foreign_key: true
  end
end
