# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class ProfilesController < ApplicationController

  def access_profile_demo
    @page_controls = access_profile_service.handle_demo_page(params)
  end
  def content_profile_demo
    @page_controls = content_profile_service.handle_demo_page(params)
  end

end
