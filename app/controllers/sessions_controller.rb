##
#
#

class SessionsController < ActionController::Base
  include Factory::ControllerMethods                 # Development Strategy
  include ApplicationHelper                          # Controller, View Helper
  include Secure::ControllerAccessControl            # Warden Security

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
    redirect_to( params.to_unsafe_h[:commit], notice: "Signed in successfully.") and return unless params.to_unsafe_h[:commit].eql?('page')
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

  private

  def do_flashes
    flash_message(:notice, warden.message) if warden.message.present?
    flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
  end
end
