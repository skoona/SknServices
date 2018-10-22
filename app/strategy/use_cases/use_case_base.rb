##
# <root>/app/strategy/use_cases/use_case_base.rb
#
# Common Base for all <Name>UseCase objects
#
# Intent:
# <Name>UseCase objects are the container and mainline for a business use case.  They may
# have many task oriented objects which they invoke to handle aspects of a use case.
#
# UseCases should limit their use of methods outside the scope of their private collection of objects,
# although they should use Service or Command object available.  We are trying to remove all Rails Framework dependencies from
# this business logic layer.  One hope is we can test without loading Rails, or the Web Framework!
#
# Domain Driven Design is the influence for this overall model.  To that end, you should:
#  - Structure ALL method names, and related task objects, to follow label names of the steps or actions from the Use Case your modeling.
#  - Wrap all physical data IO and WebService/RestFul data IO in Task Specific Class which you instantiate to acquire the data.  Make them easily mockable!
#  - Consider creating a Service class or creating a TaskClass to handle single responsibility task, rather than fat methods.
#  - TaskClasses should return 'self' on every method call; using a established callback_method protocol on your UseCase class.
#
# Inherited By:
# They are normally directly inherited by <Name>UseCase, which are responsible
# for wrapping the request/response entry-point into it multi-step use case.
#
# Instantiated By: ServiceRegistry, from <root>/app/strategy/services/service_registry.rb
#
# Description:
# This module contains the #initialize method for all inherited Classes.  It provides a common
# instantiation method providing the #registry object and the #current_user object.
#
# #registry
# - Provides access to all the other Strategy containers or objects via #<other_service>.service_method,
#   and the invoking Controller via #<some_controller_method>
# - Provides #get_session_param and #set_session_param
# - Access an in-memory object/data storage container, #create_storage_key_and_store_object, #update_storage_object, #get_storage_object, #delete_storage_object
#
# #current_user
# - Provides local access to the user object for this request cycle.  You could alternately ask the controller for this same
#   value, but that is discouraged at the domain level (thats what strategy.services do!)
#
module UseCases
  class UseCaseBase

    attr_accessor :registry

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "#{self.class.name}: Missing required initialization param!" if @registry.nil?
    end

    def self.inherited(klass)
      Rails.logger.debug("#{self.name} inherited By #{klass.name}")
    end

  private

    # Implements a 'bare words' like feature for dependency injection using ServiceRegistry
    def method_missing(method, *args, &block)
      calling_method = caller_locations(1, 2)[1]
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: ##{method}, from #{calling_method.path}##{calling_method.label}")

      block_given? ? registry.send(method, *args, block) :
          (args.size == 0 ?  registry.send(method) : registry.send(method, *args))
    end

  end
end
