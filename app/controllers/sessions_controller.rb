class SessionsController < ActionController::Base
  include Secure::ControllerAccessControl
  include ApplicationHelper
  layout "application"

  before_action :do_flashes

  # GET
  def new
  end

  # POST From New page
  def create
    #warden.reset_session!
    authenticate!(scope: :access_profile, message: "Signed in successfully.  SessionsController#create")
    flash_message(:notice, warden.message)
    redirect_to_target_or_default home_pages_url # "Signed in successfully."
  end

  # DELETE Logout
  def destroy
    logout()
    flash_message(:notice, "You have been signed out.  SessionsController#destroy")
    redirect_to home_pages_url
  end

  def unauthenticated
  end

  private

  def do_flashes
    flash_message(:alert, warden.message) if warden.message.present?
    flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
  end
end
