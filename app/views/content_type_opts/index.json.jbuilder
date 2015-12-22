json.array!(@content_type_opts) do |content_type_opt|
  json.extract! content_type_opt, :id, :value, :description, :content_type_id
  json.url content_type_opt_url(content_type_opt, format: :json)
end
