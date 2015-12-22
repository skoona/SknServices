json.array!(@content_types) do |content_type|
  json.extract! content_type, :id, :name, :description, :value_data_type
  json.url content_type_url(content_type, format: :json)
end
