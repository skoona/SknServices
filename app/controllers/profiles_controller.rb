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
    @page_controls = access_profile_service.accessible_content(params)
    results = @page_controls.to_hash
    if @page_controls.package.success
      render json: results.as_json(root: false), status: :accepted, layout: false, content_type: 'text/plain' and return
    else
      render json: results.as_json(root: false), status: :conflict, layout: false, content_type: 'text/plain' and return
    end
  end

  def available_content(params)
    @page_controls = access_profile_service.accessible_content(params)
    results = @page_controls.to_hash
    if @page_controls.package.success
      render json: results.as_json(root: false), status: :accepted, layout: false, content_type: 'text/plain' and return
    else
      render json: results.as_json(root: false), status: :conflict, layout: false, content_type: 'text/plain' and return
    end
  end

end
