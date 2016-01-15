class ApplicationController < ActionController::Base
  include Secure::ControllerAccessProfile
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :establish_domain_services, :login_required

  after_action  :manage_domain_services


  delegate :password_service, :access_profile_service, :content_profile_service,
           to: :service_factory


  # New Services extension
  def service_factory
    @service_factory ||= ::ServiceFactory.new({controller: self})
  end


  protected

  def json_request?
    request.format.json?
  end

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    logout()
    flash_message(:alert, "An unverified request was received! For security reasons you have been signed out.  ApplicationController#handle_unverified_request")
    super
  end

  def establish_domain_services
    service_factory
    flash_message(:alert, warden.message) if warden.message.present?
    flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
    Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
    true
  end

  # Serialize to user session
  def manage_domain_services
    unless controller_name.include?("sessions")
      Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
    end
    true
  end

end
