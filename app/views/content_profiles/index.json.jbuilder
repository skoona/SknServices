json.array!(@content_profiles) do |content_profile|
  json.extract! content_profile, :id, :person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email
  json.url content_profile_url(content_profile, format: :json)
end
