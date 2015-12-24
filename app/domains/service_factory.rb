## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object for DomainServices
# - Domain services live for one request cycle and are expensive to create, this object memotize them
# - This factory should be passed around like "factory" was
# - Should make testing easier
#


class ServiceFactory < ::Factory::DomainServices

  # attr_accessor :factory, :user, :current_user  -- initialize by service factory

  def password_service
    @ct_password_service ||= ::PasswordService.new({factory: self})
    yield @ct_password_service if block_given?
    @ct_password_service
  end
  def access_profile_service
    @ct_access_profile_service ||= ::AccessProfileService.new({factory: self})
    yield @ct_access_profile_service if block_given?
    @ct_access_profile_service
  end
  def content_profile_service
    @ct_content_profile_service ||= ::ContentProfileService.new({factory: self})
    yield @ct_content_profile_service if block_given?
    @ct_content_profile_service
  end

end