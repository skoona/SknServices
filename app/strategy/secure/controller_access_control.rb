##
# <Rails.root>/lib/Secure/controller_access_profile.rb
#
# This module is included in your application controller which makes
# several methods available to all controllers and views.
#
# RailsWarden auto includes via
#     RailsWarden::Mixins::HelperMethods,          :warden, :logged_in?, :authenticated?, :current_user, :user
#     RailsWarden::Mixins::ControllerOnlyMethods   :authenticate, :authenticate!, :logout
#     to ::ActionController::Base
# RailsWarden auto includes via
#     RailsWarden::Mixins::HelperMethods
#     to ::ApplicationHelper
#
# You must restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required
#
#  depends on: rails_warden.gem
#     ref: https://github.com/hassox/rails_warden
#
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3.13.2013

module Secure
  module ControllerAccessControl
    extend ActiveSupport::Concern

    included do |klass|
      Rails.logger.debug("Secure::ControllerAccessControl included By #{klass.name}")
      send( :helper_method, [ :accessed_page_name,
                              :accessed_page,
                              :page_action_paths,
                              :service_factory,
                              :current_user_has_access?,
                              :current_user_has_read?,
                              :current_user_has_create?,
                              :current_user_has_update?,
                              :current_user_has_delete?
                            ]
      )
      unless self.name.eql?('SessionsController') or self.name.eql?('ActionView::TestCase::TestController')
        Rails.logger.debug("Secure::ControllerAccessControl Activated!")
        send( :before_action, :establish_domain_services)
        send( :before_action, :login_required)
        send( :after_action,  :manage_domain_services)
        send( :rescue_from,   ActionController::UnknownFormat, {with: :raise_not_found})
        send( :protect_from_forgery )
      end

    end

    # New Services extension
    def service_factory
      @service_factory ||= ::ServiceFactory.new({factory: self})
      @service_factory_methods ||= @service_factory.public_methods
      yield @service_factory if block_given?
      @service_factory
    end

    def login_required
      public_page = Secure::AccessRegistry.security_check?(accessed_page) # TODO this is a bypass for non-secure pages, require tight AR
      unless public_page
        unless authenticated?
          store_target_location
          Rails.logger.debug("#{self.class.name.to_s}##{__method__}(public:#{public_page}): Restricted Page '#{accessed_page}' accessed, redirecting to UnAuthenticated page. #{controller_name}#login_required")
          flash_message(:alert, "You must sign in before accessing the '#{accessed_page_name}' page.  #{controller_name}#login_required")
          redirect_to unauthenticated_sessions_url
        else
          # This is the sole page level access control, based on controller/action URI entries in the access registry
          unless current_user_has_access?(accessed_page)
            flash_message(:alert, "You are not authorized to access the #{accessed_page_name} page!  #{controller_name}#login_required")
            redirect_to not_authorized_sessions_url
          end
        end
      else
        flash.delete(:notice) if !!flash.notice and !flash.notice.first.nil? and flash.notice.include?("Please sign in to continue")
      end
      Rails.logger.debug("#{self.class.name.to_s}##{__method__}(public:#{public_page}): Page '#{accessed_page}' accessed by user '#{current_user.name  if current_user.present?}'")
    end

    def redirect_to_target_or_default(default, *args)
      redirect_to(session[:return_to] || default, *args)
      session[:return_to] = nil
    end

    def json_request?
      request.format.json?
    end

    def accessed_page_name
      Secure::AccessRegistry.get_resource_description(accessed_page) || ""
    end

    def accessed_page
      "#{controller_name}/#{action_name}"
    end

    def flash_message(type, text)
      if flash[type].present? and flash[type].is_a?(Array)
        flash[type] << text
      elsif flash[type].present? and flash[type].is_a?(String)
        flash[type] = [flash[type], text]
      else
        flash[type] = [text]
      end
    end

    # called from a engine to check access with status
    def current_user_has_access?(uri, options=nil)
      opts = options || current_user.try(:user_options) || nil
      current_user.present? and current_user.has_access?(uri, opts)
    end
    # called from a engine to check access with status
    def current_user_has_create?(uri, options=nil)
      opts = options || current_user.try(:user_options) || nil
      current_user.present? and current_user.has_create?(uri, opts)
    end
    # called from a engine to check access with status
    def current_user_has_read?(uri, options=nil)
      opts = options || current_user.try(:user_options) || nil
      current_user.present? and current_user.has_read?(uri, opts)
    end
    # called from a engine to check access with status
    def current_user_has_update?(uri, options=nil)
      opts = options || current_user.try(:user_options) || nil
      current_user.present? and current_user.has_update?(uri, opts)
    end
    # called from a engine to check access with status
    def current_user_has_delete?(uri, options=nil)
      opts = options || current_user.try(:user_options) || nil
      current_user.present? and current_user.has_delete?(uri, opts)
    end

    ### Converts named routes to string
    #  Basic '/some/hardcoded/string/path'
    #        '[:named_route_path]'
    #        '[:named_route_path, {options}]'
    #        '[:named_route_path, {options}, '?query_string']'
    #
    # Advanced ==> {engine: :demo,
    #               path: :demo_profiles_path,
    #               options: {id: 111304},
    #               query: '?query_string'
    #              }
    #              {engine: :sym, path: :sym , options: {}, query: ''}
    def page_action_paths(paths)
      case paths
        when Array
          case paths.size
            when 1
              send( paths[0] )
            when 2
              send( paths[0], paths[1] )
            when 3
              rstr = send( paths[0], paths[1] )
              rstr + paths[2]
          end

        when Hash
          rstr = send(paths[:engine]).send(paths[:path], paths.fetch(:options,{}) )
          rstr + paths.fetch(:query, '')

        when String
          paths
      end
    rescue
      '#page_action_error'
    end


    protected

    def store_target_location
      session[:return_to] = request.original_url
    end

    # Force signout to prevent CSRF attacks
    def handle_unverified_request
      logout()
      flash_message(:alert, "An unverified request was received! For security reasons you have been signed out.  ApplicationController#handle_unverified_request")
      super
    end

    def raise_not_found
      render(text: 'Not acceptable', status: 406)
    end

    # Enhance the PERF Logger output
    # see: config/initializers/notification_logger.rb
    def append_info_to_payload(payload)
      super
      payload[:session_id] = request.session_options[:id] || 'na'
      payload[:uuid] = request.uuid || 'na'
      payload[:username] = current_user.present? ? current_user.username :  'no-user'
    end

    # DeSerialize from Session
    def establish_domain_services
      service_factory
      flash_message(:notice, warden.message) if warden.message.present?
      flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
      # your code here
      Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
      true
    end

    # Serialize to session
    def manage_domain_services
      unless controller_name.include?("sessions")
        # your code here
        Rails.logger.debug "#{self.class.name}.#{__method__}() Called for session.id=#{request.session_options[:id]}"
      end
      true
    end

    # Easier to code than delegation, or forwarder
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method.inspect}")
      if @service_factory_methods.try(:include?, method)
        block_given? ? @service_factory.send(method, *args, block) :
            (args.size == 0 ?  @service_factory.send(method) : @service_factory.send(method, *args))
      else
        super
      end
    end

  end # end ControllerAccessProfile
end # end Secure
