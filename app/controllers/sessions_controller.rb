class SessionsController < ActionController::Base
  include Secure::AuthenticationControllerHelper
  layout "application"

  def new
    # flash.clear
    flash.now.alert = warden.message if warden.message.present?
  end

  # From New page
  def create
    #warden.reset_session!
    authenticate!(:scope => :default)
    redirect_to_target_or_default home_url, :notice => warden.message # "Signed in successfully."
  end

  # Logout
  def destroy
    logout(:default)
    warden.reset_session!
    redirect_to root_url, :notice => "You have been signed out."
  end

end
