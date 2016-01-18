##
# app/services/access_services.rb
#
# Manages Access  interactions for Users

class AccessServices < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='access'


  def user_accessible_content(user_profile, context=PROFILE_CONTEXT, profile=nil)
    [
        {source: "datafiles", filename: "someFile.dat", created: user_profile.last_access, size: "0"},
        {source: "images",    filename: "somePic.png",  created: user_profile.last_access, size: "0"},
        {source: "pdfs",      filename: "someFile.pdf", created: user_profile.last_access, size: "0"}
    ]
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
