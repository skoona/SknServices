##
# lib/factory/domains_base.rb
#
# Common Base for all <Name>Domain objects
#
# Intent:
# <Name>Domain object are the container and mainline for a business process.  They may
# have many task oriented objects which they invoke to handle aspects of a process request.  Domain
# Classes should limit their use of methods outside the scope of their private collection of objects,
# and that of other service/domains.  We are trying to remove all Rails or Framework dependencies from
# this business logic layer.  One hope is we can test without loading Rails, or the Web Framework!
#
# Domain Driven Design is the influence for this overall model.  To that end, you should:
#  - Structure ALL method names, and related task objects, to follow label names of the steps or actions from the business process your modeling.
#  - Restrict accessing Framework services, mandate your DomainService object to enrich you input params package instead.
#  - Wrap all physical data IO and WebService/RestFul data IO in Task Specific Class which you instantiate to acquire the data.  Make them easily mockable!
#  - Consider enhancing the DomainService class or creating a TaskClass to handle single responsibility task, rather than fat methods.
#  - TaskClasses should return 'self' on every method call; using a established callback_method protocol on your domain class.
#
# Inherited By:
# They are normally directly inherited by <Name>Service, which are responsible
# for wrapping the request/response to an external Framework, typically Rails/Controller/View
#
# Instantiated By: ServiceFactory, from <root>/app/domains/service_factory.rb
#
# Description:
# This module contains the #initialize method for all inherited Classes.  It provides a common
# instantiation method providing the #factory object and the #current_user object.
#
# Class Model and Request Flow:
#                                                                       ServiceFactory#name1_service >> Name1Domain#some_method  >|
#   Rack(Warden middleware) >> Router >> Controller#url_named_method >> ServiceFactory#name2_service >> Name2Domain#some_method  >|
#                                                                       ServiceFactory#nameX_service >> NameXDomain#some_method  >|
#   Rack(Warden middleware) << ActionView#NameView#render << Controller#url_named_method << --------------------------------------|
#
# #factory
# - Provides access to all the other <Name>Services objects via #factory.other_service.service_method,
#   and the invoking Controller via #factory.controller.some_method
# - Provides #get_session_param and #set_session_param
# - Access an in-memory object/data storage container, #save_new_object, #set_existing_object, #get_existing_object, #remove_existing_object
#
# #current_user
# - Provides local access to the user object for this request cycle.  You could alternately ask the controller for this same
#   value, but that is discouraged at the domain level (thats what services do!)
#
module Factory
  class DomainsBase

    attr_accessor :factory

    def initialize(params={})
      @factory = params[:factory]
      @user = @factory.current_user unless @factory.nil?
      raise ArgumentError, "Factory::DomainsBase: for #{self.class.name}.  Missing required initialization param(factory)" if @factory.nil?
    end

    def current_user
      @user ||= @factory.current_user
    end

  end
end
