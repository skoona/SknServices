class ApplicationController < ActionController::Base
  include Secure::AuthenticationControllerHelper
  include ApplicationHelper
  #include LayoutHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery

  before_action :login_required

  private

  # AngularJS automatically sends CSRF token as a header called X-XSRF
  # this makes sure rails gets it
  def verified_request?
    !protect_against_forgery? || request.get? ||
        form_authenticity_token == params[request_forgery_protection_token] ||
        form_authenticity_token == request.headers['X-XSRF-Token'] ||
        form_authenticity_token == request.headers['X-CSRF-Token']
  end

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    logout(:default)
    super
  end

end
