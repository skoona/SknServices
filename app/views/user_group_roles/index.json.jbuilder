json.array!(@user_group_roles) do |user_group_role|
  json.extract! user_group_role, :id, :name, :description, :group_type
  json.url user_group_role_url(user_group_role, format: :json)
end
