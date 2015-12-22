json.array!(@profile_types) do |profile_type|
  json.extract! profile_type, :id, :name, :description
  json.url profile_type_url(profile_type, format: :json)
end
