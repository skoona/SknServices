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
    @page_controls = service_factory.access_service.handle_system_information_api(params.to_unsafe_h)
    redirect_to details_sysinfo_pages_path, notice: @page_controls.message and return
  end

  def details_sysinfo
    @page_controls = service_factory.access_service.handle_system_information(params.to_unsafe_h)
    flash[:notice] = @page_controls.message if @page_controls.message?
  end


end
