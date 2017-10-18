# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class ProfilesController < ApplicationController

  def in_action
    wrap_html_response content_service.handle_in_action, root_path
  end

  def in_action_admin
    wrap_html_response content_service.handle_in_action_admin(params.to_unsafe_h)
  end

  # json api, requires :username and access: [:access, :content]
  # - returns Accessible Content
  # GET
  # Parameters: {"user_options"=>nil, "name"=>"Services.Action.Developer", "description"=>"Developer", "type"=>"EmployeePrimary", "username"=>"developer", "authenticity_token"=>"mtZTAtBUxcvFqSBLtj7swsEt+OVfdG6Nu6opqkKxw5cHM6FEWPB6Z0GmXgVCyVUMhNCW3e91cKII2rpOhI614g==",
  #             }
  # Parameters: {"user_options"=>nil, "description"=>"Determine which branch documents can be seen", "username"=>"developer", "topic_value"=>"Branch", "content_value"=>["68601", "68602", "68603"], "content_type"=>"Commission", "content_type_description"=>"Monthly Commission Reports and Files", "topic_type"=>"Branch", "topic_type_description"=>"Branch Actions", "authenticity_token"=>"7jvrpk4eamg4grn04KQt73TwKY6PG2A05w7d7EqMKKRz3hngxrrVxLyNx7oUU5QhMQ1Htj8afhtUfk4IjLNe0Q==",
  #             }
  def api_accessible_content
    wrap_json_response content_service.handle_api_accessible_content(params.to_unsafe_h)
  end

  # get
  def api_get_content_object
    @page_controls = content_service.api_get_content_object(params.to_unsafe_h)
    return render( plain: "File not available!", status: :not_found ) unless @page_controls.success and @page_controls.package.package.source?
    send_file(@page_controls.package.package.source, filename: @page_controls.package.package.filename, type: @page_controls.package.package.mime, disposition: :inline) and return
  end
  # get
  def api_get_demo_content_object
    @page_controls = content_service.api_get_demo_content_object(params.to_unsafe_h)
    return render( plain: "File not available!", status: :not_found ) unless @page_controls.success and @page_controls.package.package.source?
    send_file(@page_controls.package.package.source, filename: @page_controls.package.package.filename, type: @page_controls.package.package.mime, disposition: :inline) and return
  end

  ##
  # Manage Content Profiles Page

  #GET
  def members
    wrap_html_response content_service.handle_members
  end

  # GET
  def member
    wrap_html_response content_service.handle_member(params.to_unsafe_h), members_profiles_url
  end

  # PUT
  def member_update
    wrap_html_and_redirect_response content_service.handle_member_updates(params.to_unsafe_h), members_profiles_url
  end

  # GET
  def in_depth
    wrap_html_response content_service.handle_content_profile_management(params.to_unsafe_h)
  end

  # POST
  # Requires userName and ProfileTypeName
  # Parameters:
  # {"profile_type_id"=>"5",
  #  "button"=>"content-profile-modal",
  #  "username"=>"bnptester",
  #  "id"=>"55da964b58249094b2c65959faf9e559"
  # }
  def create_profile_for_user
    wrap_html_and_redirect_response content_service.handle_content_profile_create(params.to_unsafe_h), in_depth_profiles_url
  end
  # POST
  # Requires userName and ProfileTypeName
  def update_profile_for_user
    wrap_html_and_redirect_response content_service.handle_content_profile_update(params.to_unsafe_h), in_depth_profiles_url
  end
  # DELETE
  # Requires Entry
  def delete_profile_for_user
    wrap_html_and_redirect_response content_service.handle_content_profile_destroy(params.to_unsafe_h), in_depth_profiles_url
  end
  # POST
  # Requires Entry Description, and topic_value with content choices
  def create_entries_for_user
    wrap_html_and_redirect_response content_service.handle_content_profile_entries_create(params.to_unsafe_h), in_depth_profiles_url
  end
  # DELETE
  # Requires Entry
  def delete_entry_for_user
    wrap_html_and_redirect_response content_service.handle_content_profile_entry_destroy(params.to_unsafe_h), in_depth_profiles_url
  end

end
