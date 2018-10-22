# strategy/registry/minimal_registry_base.rb
#
# Common Base for Independent DI Service Classes, with option to join Registry for DI
#

module Registry
  class MinimalRegistryBase

    attr_accessor :registry


    def self.call(parms: {}, depends: {})
      new(depends).call(parms)
    end

    def call(params={})
      raise NotImplementedError, "#{self.class.name}##{__method__}() method has not been implemented!"
    end

    # ##
    # params  = {user_data: <user-data>}
    # depends = {some_useful_thingy: SomeUsefulThingy.new,
    #            policy_service: self.policy_service,
    #            registry: self        #self assumes Registry instance
    #           }
    def initialize(depends={})
      depends.keys.each do |k|
        instance_variable_set "@_#{k.to_s}".to_sym, nil
        instance_variable_set "@_#{k.to_s}".to_sym, depends[k]
      end
    end

    # ##
    # results = @_some_useful_thingy.my_method(pol_id)
    # policy  = @_policy_service.get_policy(pol_id)

    private

    # Implements a 'bare words' like feature for dependency injection using Registry
    def method_missing(method, *args, &block)
      calling_method = caller_locations(1, 2)[1]
      puts("#{self.class.name}##{__method__}() looking for: ##{method}, from #{calling_method.path}##{calling_method.label}")

      if defined?(@_registry)
        block_given? ? @_registry.send(method, *args, block) :
            (args.size == 0 ?  @_registry.send(method) : @_registry.send(method, *args))
      else
        super
      end

    end

  end
end


