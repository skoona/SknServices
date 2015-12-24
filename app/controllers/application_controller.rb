class ApplicationController < ActionController::Base
  include Secure::AuthenticationControllerHelper
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery

  before_action :login_required, :establish_domain_services
  after_action  :manage_domain_services


  delegate :password_service, :access_profile_service, :content_profile_service,
           to: :service_factory


  # New Services extension
  def service_factory
    @service_factory || ::ServiceFactory.new({factory: self})
  end


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

  def establish_domain_services
    service_factory
    Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
  end

  # Serialize to user session
  def manage_domain_services
    unless controller_name.include?("sessions")
      # session[:page_info_domain] = page_info_domain if @page_info_domain.present?
      Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
    end
  end

end
