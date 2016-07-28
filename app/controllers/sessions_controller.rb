class SessionsController < ActionController::Base
  include Secure::ControllerAccessControl, ApplicationHelper
  layout "application"

  before_action :do_flashes

  # GET
  def new
  end

  # POST From New page then commit=page     -- redirect as normal
  # POST From Modal then commit=modal       -- leave on current page
  def create
    #warden.reset_session!
    authenticate!(scope: :access_profile, message: "Signed in successfully.  SessionsController#create")
    flash_message(:notice, warden.message)
    redirect_to( params[:commit], notice: "Signed in successfully.") and return unless params[:commit].eql?('page')
    redirect_to_target_or_default home_pages_url  # "Signed in successfully."
  end

  # DELETE Logout
  def destroy
    logout()
    flash_message(:notice, "You have been signed out.  SessionsController#destroy")
    redirect_to home_pages_url
  end

  def unauthenticated
  end

  def not_authorized
  end

  protected

  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end

  def accessed_page_name
    Secure::AccessRegistry.get_resource_description(accessed_page) || ""
  end

  def accessed_page
    "#{controller_name}/#{action_name}"
  end

  def flash_message(type, text)
    if flash[type].present? and flash[type].is_a?(Array)
      flash[type] << text
    elsif flash[type].present? and flash[type].is_a?(String)
      flash[type] = [flash[type], text]
    else
      flash[type] = [text]
    end
  end

  private

  def do_flashes
    flash_message(:notice, warden.message) if warden.message.present?
    flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
  end
end
