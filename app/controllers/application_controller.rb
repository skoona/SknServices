##
#
#

class ApplicationController < ActionController::Base
  include Registry::RegistryMethods                 # Development Strategy
  include ApplicationHelper                          # Controller, View Helper
  include Secure::AccessAuthenticationMethods            # Warden Security

  protected
  
  def wrap_html_response(service_response, redirect_path=root_path)
    @page_controls = service_response
    flash[:notice] = @page_controls.message if @page_controls.message.present?
    redirect_to redirect_path, notice: @page_controls.message and return unless @page_controls.success
  end

  def wrap_html_and_redirect_response(service_response, redirect_path=root_path)
    @page_controls = service_response
    flash[:notice] = @page_controls.message if @page_controls.message.present?
    redirect_to redirect_path, notice: @page_controls.message and return
  end

  def wrap_json_response(service_response)
    @page_controls = service_response
    render(json: @page_controls.to_hash, status: (@page_controls.package.success ? :accepted : :not_found), layout: false, content_type: :json) and return
  end

end
