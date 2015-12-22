json.array!(@content_profile_entries) do |content_profile_entry|
  json.extract! content_profile_entry, :id, :topic_value, :content_value, :content_type_id, :topic_type_id, :content_profile_id
  json.url content_profile_entry_url(content_profile_entry, format: :json)
end
