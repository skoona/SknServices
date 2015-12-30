##
#
# Inherited by: ContentProfileService, AccessProfileService
#
#

class ContentProfileDomain < ::Factory::DomainServices

  attr_accessor :page_user

  def get_page_users
    usrs = []
    Secure::UserProfile.page_users.each do |u|
      usrs << {username: u.last, display_name: u.first}
    end
    usrs
  end
  def get_user_form_options
    SknUtils::PageControls.new({
                                   groups: group_select_options,
                                   roles: role_select_options
                               })
  end

  def get_page_user(uname)
    page_user = Secure::UserProfile.page_user(uname)
  end

  def get_page_access_profile
    page_user.access_profile(true)
  end

  def get_page_content_profile
    page_user.content_profile.to_hash
  end

  def group_select_options
    UserGroupRole.all().map do |r|
      [r.description, r.name]
    end
  end
  def role_select_options
    UserRole.all().map do |r|
      [r.description, r.name]
    end
  end

end