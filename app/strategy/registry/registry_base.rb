# lib/registry/factories_base.rb
#
# Common Base for ServiceRegistry oriented Classes
# - Expect to have one ServiceRegistry per Engine or App
#

module Registry
  class RegistryBase
    include Registry::ObjectStorageService

    attr_accessor :registry

    def self.inherited(klass)
      klass.send(:oscs_set_context=, klass.name)
      Rails.logger.debug("#{self.name} inherited By #{klass.name}")
    end

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "ServiceRegistry: Missing required initialization param!" if @registry.nil?
    end

    # User Session Handler
    def get_session_param(key)
      @registry.session[key]
    end

    def set_session_param(key, value)
      @registry.session[key] = value
    end

    # Not required, simply reduces traffic since it is called often
    def current_user
      @current_user ||= registry.current_user
    end

    protected

    # Support the regular respond_to? method by
    # answering for any method the controller actually handles
    #:nodoc:
    def respond_to_missing?(method, incl_private=false)
      registry.send(:respond_to?, method, incl_private) || super
    end


  private

    # Easier to code than delegation, or forwarder; @registry assumed to equal @controller
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
      if registry.respond_to?(method)
        block_given? ? registry.send(method, *args, block) :
            (args.size == 0 ?  registry.send(method) : registry.send(method, *args))
      else
        super
      end
    end

  end
end


