##
# File: <root>/lib/factory/task_adapters_base.rb
#
# Retrieves content for target system

module Processors
  class ProcessorBase

    attr_accessor :factory

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "ServiceFactory: Missing required initialization param!" if @factory.nil?
    end

    def self.inherited(klass)
      Rails.logger.debug("Factory::DomainsBase inherited By #{klass.name}")
    end

    def ready?
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end

    # Ruby only Alternate: MIME::Types.type_for(full_filename), using mime.gem
    def content_mime_type(extension)
      extname = extension.gsub(/^\./,'')
      return 'text/plain' if extname.downcase.include?('log')
      Mime::Type.lookup_by_extension(extname).to_str rescue 'application/octet-stream'
    end

    ##
    # Transaction request enables caller to execute public methods on this object
    #
    # provider.transaction_request(self) do |prov|
    #   prov.provider_method(params)
    #   prov.special_provider_method_that_needs_a_callback(callback, params)
    # end
    #
    def transaction_request(callback, &block)
      block.call(self)
      Rails.logger.debug "transaction_request(Complete) for #{callback.class.name}"
      true
    rescue Exception => e
      Rails.logger.debug "transaction_request(EXCEPTION) #{e.class.name.to_s} #{e.message} #{e.backtrace[0..3].join("\n")}"
      false
    end

  protected

    def get_page_user(uname, context=nil)
      page_user = Secure::UserProfile.page_user(uname, context)
    end

    def sanitize(filename)
      value = filename
      # Remove any leading navigation
      value = value[2..-1] if value.start_with?('..')
      value = value[2..-1] if value.start_with?('./')
      value = value[1..-1] if value.start_with?('/')
      # Remove any character that aren't 0-9, A-Z, or a-z
      value = value.gsub(/[^0-9A-Z]/i, '_')
      value
    end

    # Rails should have a 'number_to_human_size()' in some version ???
    def human_filesize(value)
      {
          'B'  => 1024,
          'KB' => 1024 * 1024,
          'MB' => 1024 * 1024 * 1024,
          'GB' => 1024 * 1024 * 1024 * 1024,
          'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.each_pair { |e, s| return "#{(value.to_f / (s / 1024)).round(1)} #{e}" if value < s }
    end

    # Easier to code than delegation, or forwarder
    # Allows strategy.domains, service, to access objects in service_factory and/or controller by name only
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
      block_given? ? factory.send(method, *args, block) :
          (args.size == 0 ?  factory.send(method) : factory.send(method, *args))
    end

  end
end
