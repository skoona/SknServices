##
# ApplicationController Mixin
#
#
module Registry
  module RegistryMethods

    def self.included(klass)
      Rails.logger.debug("#{self.name} included By #{klass.name}")
      klass.send( :helper_method, [ :accessed_page_name, :accessed_page])

      klass.send( :before_action, :establish_domain_services)
      klass.send( :after_action,  :persist_domain_services)
      Rails.logger.info("#{self.name} Activated!")
      nil
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
    end

    protected

    def wrap_html_response(service_response, redirect_path=root_path)
      @page_controls = service_response
      flash[:notice] = @page_controls.message if @page_controls.message.present?
      redirect_to redirect_path, notice: @page_controls.message and return unless @page_controls.success
    end

    def wrap_html_and_redirect_response(service_response, redirect_path=root_path)
      @page_controls = service_response
      flash[:notice] = @page_controls.message if @page_controls.message.present?
      redirect_to redirect_path, notice: @page_controls.message and return
    end

    def wrap_json_response(service_response)
      @page_controls = service_response
      render(json: @page_controls.to_hash, status: (@page_controls.package.success ? :accepted : :not_found), layout: false, content_type: :json) and return
    end

    def wrap_file_response(service_response)
      return render( plain: "File not available!", status: :not_found ) unless service_response.success and service_response.package.package.source?
      send_file(service_response.package.package.source, filename: service_response.package.package.filename, type: service_response.package.package.mime, disposition: :inline) and return
    end

    # Call or Restore app services
    def establish_domain_services
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

    # Easier to code than delegation, or forwarder
    # While :establish_domain_services invokes the service_factory to initialize it,
    # be sure to call the :service_factory method rather than the instance method here.
    def method_missing(method, *args, &block)
      calling_method = caller_locations(1, 2)[1]
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: ##{method}, from #{calling_method.path}##{calling_method.label}")

      if service_registry.public_methods(false).try(:include?, method)
        block_given? ? service_registry.send(method, *args, block) :
            (args.size == 0 ?  service_registry.send(method) : service_registry.send(method, *args))
      else
        super
      end
    end

  end
end