# lib/factory/providers_base.rb
#
# Common Base for all Services oriented Classes, without Domains
#

module Factory
  class ProvidersBase
    include Factory::ObjectStorageService

    attr_accessor :user, :factory

    def self.inherited(klass)
      klass.send(:oscs_set_context=, klass.name)
      Rails.logger.debug("Factory::ProvidersBase inherited By #{klass.name}")
    end

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "Providers: Missing required initialization param!" if @factory.nil?
      @user = @factory.current_user unless @user
    end

    ##
    # Same for current_user, a controller value
    def current_user
      @user ||= @factory.current_user
    end

    ##
    # Retrieves Existing ContentProfile for ContentProviders
    def get_prebuilt_profile(pak)
      profile = nil
      profile = get_storage_object(pak)
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{profile}")
      profile
    end

    protected

    # Support the regular respond_to? method by
    # answering for any attr that user_object actually handles
    #:nodoc:
    # def respond_to_missing?(method, incl_private=false)
    #   @factory.send(:respond_to?, method) || super(method,incl_private)
    # end


    private

    # some_instance_var?
    def attribute?(attr)
      if attr.is_a? Symbol
        send(attr).present?
      else
        send(attr.to_sym).present?
      end
    end

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
        elsif method.to_s.end_with?('?')
          if instance_variable_defined?("@#{method.to_s[0..-2]}")
            attribute?(method.to_s[0..-2].to_sym)
          else
            false
          end
        else
          super(method, *args, &block)
        end
      else
        super(method, *args, &block)
      end
    end

  end
end

