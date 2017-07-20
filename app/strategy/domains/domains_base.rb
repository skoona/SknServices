##
# lib/registry/domains_base.rb
#
# Common Base for all <Name>Domain objects
#
# Intent:
# <Name>Domain object are the container and mainline for a business process.  They may
# have many task oriented objects which they invoke to handle aspects of a process request.  Domain
# Classes should limit their use of methods outside the scope of their private collection of objects,
# and that of other service/strategy.domains.  We are trying to remove all Rails or Framework dependencies from
# this business logic layer.  One hope is we can test without loading Rails, or the Web Framework!
#
# Domain Driven Design is the influence for this overall model.  To that end, you should:
#  - Structure ALL method names, and related task objects, to follow label names of the steps or actions from the business process your modeling.
#  - Restrict accessing Framework strategy.services, mandate your DomainService object to enrich you input params package instead.
#  - Wrap all physical data IO and WebService/RestFul data IO in Task Specific Class which you instantiate to acquire the data.  Make them easily mockable!
#  - Consider enhancing the DomainService class or creating a TaskClass to handle single responsibility task, rather than fat methods.
#  - TaskClasses should return 'self' on every method call; using a established callback_method protocol on your domain class.
#
# Inherited By:
# They are normally directly inherited by <Name>Service, which are responsible
# for wrapping the request/response to an external Framework, typically Rails/Controller/View
#
# Instantiated By: ServiceRegistry, from <root>/app/strategy.domains/service_registry.rb
#
# Description:
# This module contains the #initialize method for all inherited Classes.  It provides a common
# instantiation method providing the #registry object and the #current_user object.
#
# Class Model and Request Flow:
#                                                                       ServiceRegistry#name1_service >> Name1Service#some_method          >|
#   Rack(Warden middleware) >> Router >> Controller#url_named_method >> ServiceRegistry#name2_service >> Name2Service#some_method          >|
#                                                                       ServiceRegistry#nameX_service >> NameX[Domain|Service]#some_method >|
#   Rack(Warden middleware) << ActionView#NameView#render << Controller#url_named_method << ------------------[ResultsBean]----------------|
#
# #registry
# - Provides access to all the other <Name>Services objects via #registry.other_service.service_method,
#   and the invoking Controller via #registry.controller.some_method
# - Provides #get_session_param and #set_session_param
# - Access an in-memory object/data storage container, #create_storage_key_and_store_object, #update_storage_object, #get_storage_object, #delete_storage_object
#
# #current_user
# - Provides local access to the user object for this request cycle.  You could alternately ask the controller for this same
#   value, but that is discouraged at the domain level (thats what strategy.services do!)
#
module Domains
  class DomainsBase

    attr_accessor :registry

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "ServiceRegistry: Missing required initialization param!" if @registry.nil?
    end

    def self.inherited(klass)
      Rails.logger.debug("Registry::DomainsBase inherited By #{klass.name}")
    end

  private

    # Easier to code than delegation, or forwarder
    # Allows strategy.domains, service, to access objects in service_registry and/or controller methods by name only
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
      block_given? ? registry.send(method, *args, block) :
          (args.size == 0 ?  registry.send(method) : registry.send(method, *args))
    end

  end
end
