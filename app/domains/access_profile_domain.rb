##
# app/services/access_profile_domain.rb
#
# Manages user access to this system and its clickables and other resources

class AccessProfileDomain < ::Factory::DomainsBase

  def reload_access_registry
    Secure::AccessRegistry.ar_reload_configuration_file()
  end

  def get_user_form_options
    SknUtils::PageControls.new({
                                   groups: group_select_options,
                                   roles: role_select_options
                               })
  end
  def group_select_options
    UserGroupRole.select_options
  end
  def role_select_options
    UserRole.select_options
  end

end