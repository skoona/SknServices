class SessionsController < ActionController::Base
  include Secure::ControllerAccessProfile
  layout "application"

  # GET
  def new
    # flash.clear
    flash.now.alert = warden.message if warden.message.present?
  end

  # POST From New page
  def create
    #warden.reset_session!
    authenticate!(scope: :access_profile, message: "Signed in successfully.")
    redirect_to_target_or_default home_url, :notice => warden.message # "Signed in successfully."
  end

  # DELETE Logout
  def destroy
    logout()
    redirect_to home_url, :notice => "You have been signed out."
  end

end
