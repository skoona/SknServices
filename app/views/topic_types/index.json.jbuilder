json.array!(@topic_types) do |topic_type|
  json.extract! topic_type, :id, :name, :description, :value_based_y_n
  json.url topic_type_url(topic_type, format: :json)
end
