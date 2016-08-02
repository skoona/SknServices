# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class ProfilesController < ApplicationController

  before_action :login_required, except: :api_get_content_object

  def content_profile_demo
    @page_controls = content_profile_service.handle_demo_page(params)
    flash.notice.now = @page_controls.message if @page_controls.message.present?
  end

  # GET
  def manage_content_profiles
    @page_controls = content_profile_service.handle_content_profile_management(params)
    flash[:notice] = @page_controls.message if @page_controls.message?
  end

  # json api, requires :username and access: [:access, :content]
  # - returns Accessible Content
  # GET
  # Parameters: {"user_options"=>nil, "name"=>"Services.Action.Developer", "description"=>"Developer", "type"=>"EmployeePrimary", "username"=>"developer", "authenticity_token"=>"mtZTAtBUxcvFqSBLtj7swsEt+OVfdG6Nu6opqkKxw5cHM6FEWPB6Z0GmXgVCyVUMhNCW3e91cKII2rpOhI614g==",
  #             }
  # Parameters: {"user_options"=>nil, "description"=>"Determine which branch documents can be seen", "username"=>"developer", "topic_value"=>"Branch", "content_value"=>["68601", "68602", "68603"], "content_type"=>"Commission", "content_type_description"=>"Monthly Commission Reports and Files", "topic_type"=>"Branch", "topic_type_description"=>"Branch Actions", "authenticity_token"=>"7jvrpk4eamg4grn04KQt73TwKY6PG2A05w7d7EqMKKRz3hngxrrVxLyNx7oUU5QhMQ1Htj8afhtUfk4IjLNe0Q==",
  #             }
  def api_accessible_content
    @page_controls = content_profile_service.api_accessible_content(params)
    render(json: @page_controls.to_hash, status: (@page_controls.package.success ? :accepted : :not_found), layout: false, content_type: :json) and return
  end

  # POST
  def api_get_content_object
    @page_controls = content_profile_service.api_get_content_object(params)
    send_file(@page_controls.package.package.source,
                filename: @page_controls.package.package.filename,
                type: @page_controls.package.package.mime,
                disposition: :inline
    ) and return
  end

end
