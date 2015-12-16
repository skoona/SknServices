##
# spec/support/access_registry_test_user.rb
#
# For RSpec Testing
#


class AccessRegistryTestUser
  include Secure::AccessControl
  attr_accessor :roles, :unique_id

  def initialize(params=nil)
    @roles = params || [] # is an [] or roles
    @unique_id = SecureRandom.hex(16)
  end

  def key
    unique_id
  end

  def set_roles(ary)
    @roles = ary
  end

end
