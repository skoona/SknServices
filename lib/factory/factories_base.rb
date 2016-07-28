# lib/factory/factories_base.rb
#
# Common Base for all Services oriented Classes, without Domains
#

module Factory
  class FactoriesBase
    include Factory::ObjectStorageService

    attr_accessor :user, :factory

    def self.inherited(klass)
      klass.send(:oscs_set_context=, klass.name)
      Rails.logger.debug("Factory::ServicesBase inherited By #{klass.name}")
    end

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "ServiceFactory: Missing required initialization param!" if @factory.nil?
      @user = @factory.current_user unless @user
    end


    ##
    # The controller knows itself as 'self'
    # so we bridge to it for our Services
    def controller
      @factory
    end

    ##
    # Same for current_user, a controller value
    def current_user
      @user ||= @factory.current_user
    end

    # User Session Handler
    def get_session_param(key)
      @factory.session[key]
    end
    def set_session_param(key, value)
      @factory.session[key] = value
    end

    protected

    # Support the regular respond_to? method by
    # answering for any attr that user_object actually handles
    #:nodoc:
    # def respond_to_missing?(method, incl_private=false)
    #   @factory.send(:respond_to?, method) || super(method,incl_private)
    # end


    private

    # Easier to code than delegation, or forwarder; @factory assumed to equal @controller
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
      if @factory
        if @factory.respond_to?(method)
          block_given? ? @factory.send(method, *args, block) :
              (args.size == 0 ?  @factory.send(method) : @factory.send(method, *args))
        elsif @factory.respond_to?(:factory) and @factory.factory.respond_to?(method)
          block_given? ? @factory.factory.send(method, *args, block) :
              (args.size == 0 ?  @factory.factory.send(method) : @factory.factory.send(method, *args))
        else
          super(method, *args, &block)
        end
      else
        super(method, *args, &block)
      end
    end

  end
end


