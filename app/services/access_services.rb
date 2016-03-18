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


  def get_unassigned_user_attributes
    results = []
    User.where.not(person_authenticated_key: ContentProfile.select(:person_authentication_key)).find_each do |rec|
      results << [ "#{rec.username} : #{rec.name}", rec.person_authenticated_key, { data: {user: {
          username: rec.username,
          person_authentication_key: rec.person_authenticated_key,
          display_name: rec.display_name,
          email: rec.email,
          authentication_provider: 'BCrypt',
          profile_type: rec.user_options.delete_if(&:blank?) }.to_json }}
      ]
    end
    results
  end
  def get_empty_new_content_profile
    ContentProfile.new
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
