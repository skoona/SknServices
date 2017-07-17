##
# Controller Mixin
#
#
module Factory
  module ControllerMethods
    extend ActiveSupport::Concern

    included(nil) do |klass|
      Rails.logger.debug("Factory::ControlerMethods included By #{klass.name}")
      send( :helper_method, [ :accessed_page_name, :accessed_page])

      unless self.name.eql?('SessionsController') or self.name.eql?('ActionView::TestCase::TestController')
        send( :protect_from_forgery )
      end

      Rails.logger.debug("Factory::ControlerMethods Activated!")
      send( :before_action, :establish_domain_services)
      send( :after_action,  :persist_domain_services)
    end

    # Enhance the PERF Logger output
    # see: config/initializers/notification_logger.rb
    def append_info_to_payload(payload)
      super
      payload[:session_id] = request.session_options[:id] || 'na'
      payload[:uuid] = request.uuid || 'na'
      payload[:username] = current_user.present? ? current_user.username :  'no-user'
    end

    def json_request?
      request.format.json?
    end

    def accessed_page_name
      Secure::AccessRegistry.get_resource_description(accessed_page) || ""
    end

    def accessed_page
      "#{controller_name}/#{action_name}"
    end

    # New Services extension
    def service_factory
      @service_factory ||= ::ServiceFactory.new({factory: self})
      yield @service_factory if block_given?
      @service_factory
    end

    protected

    # Call or Restore app services
    def establish_domain_services
      service_factory
      flash_message(:notice, warden.message) if warden.message.present?
      flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
      # your code here
      Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}, Original-URL: #{request.original_url}"
      true
    end

    # Serialize to session key app services
    def persist_domain_services
      unless controller_name.include?("sessions")
        # your code here
        Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
      end
      true
    end

    # Force signout to prevent CSRF attacks
    def handle_unverified_request
      logout()
      flash_message(:alert, "An unverified request was received! For security reasons you have been signed out.  ApplicationController#handle_unverified_request")
      super
    end

    # Easier to code than delegation, or forwarder
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method.inspect}")
      if service_factory.public_methods.try(:include?, method)
        block_given? ? service_factory.send(method, *args, block) :
            (args.size == 0 ?  service_factory.send(method) : service_factory.send(method, *args))
      else
        super
      end
    end

  end
end