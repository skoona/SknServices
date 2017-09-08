##
# Controller Mixin
#
#
module Registry
  module RegistryMethods

    def self.included(klass)
      Rails.logger.debug("#{self.name} included By #{klass.name}")
      klass.send( :helper_method, [ :accessed_page_name, :accessed_page])

      unless ['SessionsController', 'ActionView::TestCase::TestController'].include?( klass.name )
        klass.send( :protect_from_forgery )
      end

      Rails.logger.info("#{self.name} Activated!")
      klass.send( :before_action, :establish_domain_services)
      klass.send( :after_action,  :persist_domain_services)
    end

    # Enhance the PERF Logger output
    # see: config/initializers/notification_logger.rb
    def append_info_to_payload(payload)
      super
      payload[:session_id] = request.session_options[:id] || 'na'
      payload[:uuid] = request.uuid || 'na'
      payload[:username] = current_user.present? ? current_user.username :  'no-user'
    end

    def accessed_page_name
      Secure::AccessRegistry.get_resource_description(accessed_page) || ""
    end

    def accessed_page
      "#{controller_name}/#{action_name}"
    end

    # New Services extension
    def service_registry
      @service_registry ||= Services::ServiceRegistry.new({registry: self})
      yield @service_registry if block_given?
      @service_registry
    end

    protected

    # Call or Restore app services
    def establish_domain_services
      service_registry
      flash_message(:notice, warden.message) if warden.message.present?
      flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
      # your code here
      Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
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
      if service_registry.public_methods.try(:include?, method)
        block_given? ? service_registry.send(method, *args, block) :
            (args.size == 0 ?  service_registry.send(method) : service_registry.send(method, *args))
      else
        super
      end
    end

  end
end