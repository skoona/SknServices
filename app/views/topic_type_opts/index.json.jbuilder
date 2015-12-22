json.array!(@topic_type_opts) do |topic_type_opt|
  json.extract! topic_type_opt, :id, :value, :description, :topic_type_id
  json.url topic_type_opt_url(topic_type_opt, format: :json)
end
