##
# app/services/profile_data_services.rb
#
# Manages Access  interactions for Users
# This is an internal service object and should not be exposed to a controller directly.
# It can do the heavy lifting for access related actions, like render content based on a profile
#


class ProfileDataServices < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='access'

  ##
  # Supporting ContentProfilesController Actions
  def get_page_pagination_for_content_profile_index(params)
    ContentProfile.paginate(page: params[:page], :per_page => 12)
  end
  def update_content_profile_from_permitted_params(permitted_params)
    content_profile_object = profile_data_services.find_content_profile_by_id(permitted_params[:id])
    content_profile_object.update!(permitted_params)
    content_profile_object
  end
  def get_empty_new_content_profile
    ContentProfile.new
  end
  def create_content_profile_from_permitted_params(permitted_params)
    ContentProfile.create!(permitted_params)
  end
  def destroy_content_profile(params)
    content_profile_object = find_content_profile_by_id(params[:id])
    content_profile_object.destroy
  end
  def get_content_profiles_entries_entry_info(existing_content_profile_object)
    existing_content_profile_object.content_profile_entries.map(&:entry_info)
  end
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
  def find_content_profile_by_id(rec_id)
    ContentProfile.find(rec_id)  # Could raise a not found exception
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
