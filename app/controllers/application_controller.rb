class ApplicationController < ActionController::Base
  include Secure::ControllerAccessControl
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :establish_domain_services

  after_action  :manage_domain_services

  helper_method :service_factory, :json_request?


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

  # Enhance the PERF Logger output
  # see: config/initializers/notification_logger.rb
  def append_info_to_payload(payload)
    super
    payload[:uuid] = request.uuid || 'na'
    payload[:username] = current_user.present? ? current_user.username :  'no-user'
  end

  # DeSerialize from Session
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

  # Easier to code than delegation, or forwarder
  def method_missing(method, *args, &block)
    Rails.logger.debug("#{self.class.name}.#{__method__}() looking for: ##{method}")
    if service_factory.respond_to?(method)
      block_given? ? service_factory.send(method, *args, block) :
          (args.size == 0 ?  service_factory.send(method) : service_factory.send(method, *args))
    else
      super(method, *args, &block)
    end
  end


end
