class SessionsController < ActionController::Base
  include Secure::ControllerAccessControl
  include ApplicationHelper
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

  # helper_method [ :accessed_page, :accessed_page_name, :redirect_to_target_or_default, :current_user_has_access? ]
  #
  # def accessed_page
  #   "#{controller_name}/#{action_name}"
  # end
  #
  # def accessed_page_name
  #   Secure::AccessRegistry.get_resource_description(accessed_page) || ""
  # end
  #
  # def redirect_to_target_or_default(default, *args)
  #   redirect_to(session[:return_to] || default, *args)
  #   session[:return_to] = nil
  # end
  #
  # def current_user_has_access?(uri, options=nil)
  #   opts = options || current_user.try(:user_options) || nil
  #   current_user.present? and current_user.has_access?(uri, opts)
  # end


  private

  def do_flashes
    flash_message(:notice, warden.message) if warden.message.present?
    flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
  end
end
