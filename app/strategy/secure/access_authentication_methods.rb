##
# <Rails.root>/app/Strategy/Secure/controller_access_profile.rb
#
# This module is included in your application controller which makes
# several methods available to all controllers and views.
#
# @See ./config/initializers/warden.rb
# Warden auto includes via
#     Warden::Mixins::Common                  :request, :response, :cookies, :raw_session, :reset_session!
#     Secure::Warden::ControllerOnlyMethods   :authenticate, :authenticate!, :logout
#     to ::ActionController::Base
# Warden auto includes via
#     Secure::Warden::HelperMethods,          :warden, :logged_in?, :authenticated?, :current_user, :user
#     to ::ApplicationHelper
#
# You must restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required
#
#  depends on: config/initializaers/warden.rb
#     ref: https://github.com/hassox/rails_warden
#
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3.13.2013

module Secure
  module AccessAuthenticationMethods

    def self.included(klass)
      Rails.logger.debug("#{self.name} included By #{klass.name}")
      klass.send( :helper_method, [:current_user_has_access?,
                             :current_user_has_read?,
                             :current_user_has_create?,
                             :current_user_has_update?,
                             :current_user_has_delete?
                            ])
      unless ['SessionsController', 'ActionView::TestCase::TestController'].include?(klass.name)
        Rails.logger.debug("Secure::AccessAuthenticationMethods Activated! #{klass.name}")
        klass.send( :before_action, :login_required)
        klass.send( :protect_from_forgery )
      end
    end

    def login_required
      public_page = Secure::AccessRegistry.security_check?(accessed_page) # TODO this is a bypass for non-secure pages, require tight AR
      unless public_page
        unless authenticated?
          store_target_location
          Rails.logger.debug("#{self.class.name}##{__method__}(public:#{public_page}): Restricted Page '#{accessed_page}' accessed, redirecting to UnAuthenticated page. #{controller_name}#login_required")
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
      Rails.logger.debug("#{self.class.name}##{__method__}(public:#{public_page}): Page '#{accessed_page}' accessed by user '#{current_user.name  if current_user.present?}'")
    end

    # Force signout to prevent CSRF attacks
    def handle_unverified_request
      logout()
      flash_message(:alert, "An unverified request was received! For security reasons you have been signed out.  ApplicationController#handle_unverified_request")
      super
    end

    def redirect_to_target_or_default(default, *args)
      redirect_to(session[:return_to] || default, *args)
      session[:return_to] = nil
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

  protected

    def store_target_location
      session[:return_to] = request.original_url
    end

  end # end ControllerAccessProfile
end # end Secure
