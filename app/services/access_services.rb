##
# app/services/access_services.rb
#
# Manages Access  interactions for Users
# This is an internal service object and should not be exposed to a controller directly.
# It can do the heavy lifting for access related actions, like render content based on a profile
#


class AccessServices < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='access'


  def user_accessible_content(topic, content)
    factory.filelist_builder.request_content_filelist({topic: topic, content: content})
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
