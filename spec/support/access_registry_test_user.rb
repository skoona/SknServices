##
# spec/support/access_registry_test_user.rb
#
# For RSpec Testing of core AR facility
#


class AccessRegistryTestUser

  attr_accessor :roles, :unique_id, :username, :assigned_roles, :display_name,
                :assigned_groups, :remember_token, :person_authenticated_key, :user_options

  def initialize(params=nil)
    @roles = params || [] # is an [] or roles
    @person_authenticated_key = @unique_id = SecureRandom.hex(16)
    @username = Faker::Internet.user_name
    @display_name = Faker::Name.name
  end

  def proxy_u
    self
  end
  def self.attribute_names
    [
      "roles", "unique_id", "username", "assigned_roles", "user_options",
      "assigned_groups", "remember_token", "person_authenticated_key"
    ]
  end
  include Secure::UserAccessControl

  def combined_access_roles
    @roles || []
  end

  def key
    unique_id
  end

  def set_roles(ary)
    @roles = ary
  end

end
