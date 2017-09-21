# All action in this controller are UnSecured
# - Please do not add anything that should not be PUBLIC

class PagesController < ApplicationController



  def home
  end

  def details_content
  end
  def details_access
  end
  def details_auth
  end
  def details_architecture
  end

  def about
  end

  # GET
  def api_sysinfo_actions
    wrap_html_and_redirect_response access_service.handle_system_information_api(params.to_unsafe_h), details_sysinfo_pages_url
  end

  def details_sysinfo
    wrap_html_response access_service.handle_system_information(params.to_unsafe_h)
  end


end
