# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class ProfilesController < ApplicationController

  def access_profile_demo
    @page_controls = access_profile_service.handle_demo_page(params)
  end
  def content_profile_demo
    @page_controls = content_profile_service.handle_demo_page(params)
  end

  # json api, requires :username and access: [:access, :content]
  # - returns Accessible Content
  def accessible_content(params)
    @page_controls = content_profile_service.accessible_content(params)
    if @page_controls.success
      render json:  {package: @page_controls.to_hash()}.as_json(root: false), status: :accepted, content_type: :json and return
    else
      render json:  {package: @page_controls.to_hash()}.as_json(root: false), status: :conflict, content_type: 'text/plain' and return
    end
  end

end
