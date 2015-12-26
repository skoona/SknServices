##
# <Rails.root>/lib/Secure/controller_authentication.rb
#
# This module is included in your application controller which makes
# several methods available to all controllers and views.
#
# You must restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3.13.2013

module Secure
  module AuthenticationControllerHelper
    extend ActiveSupport::Concern

    included do
      send :helper_method, :login_required, :redirect_to_target_or_default,
           :accessed_page_name, :accessed_page, :valid_user_has_access?,
           :has_access?, :current_user_has_access? if respond_to?(:helper_method)
    end


    def login_required
      unless AccessRegistry.security_check?(accessed_page) # TODO this is a bypass for non-secure pages, require tight AR
        unless authenticated?
          store_target_location
          Rails.logger.debug("Restricted Page '#{accessed_page}' accessed, redirecting to Sign in page")
          redirect_to signin_url, :alert => "You must sign in before accessing the '#{accessed_page_name}' page."
        else
          # This is the sole page level access control, based on controller/action URI entries in the access registry
          redirect_to home_url, :alert => "You are not authorized to access the #{accessed_page_name} page!" unless current_user_has_access?(accessed_page)
        end
      else
        flash.delete(:notice) if flash.notice.eql?("Please sign in to continue.")
      end
      Rails.logger.debug("Page '#{accessed_page}' accessed by user '#{current_user.name  if current_user.present?}'")
    end

    def redirect_to_target_or_default(default, *args)
      redirect_to(session[:return_to] || default, *args)
      session[:return_to] = nil
    end

    def accessed_page_name
      AccessRegistry.get_resource_description(accessed_page) || ""
    end

    def accessed_page
      "#{controller_name}/#{action_name}"
    end

    def valid_user_has_access?(uri, options=nil)
      logged_in? and current_user_has_access?(uri, options)
    end

    # called from a engine to check access with status
    def current_user_has_access?(uri, options=nil)
      opts = options || session[:security_options] || nil
      current_user.present? and current_user.has_access?(uri, opts)
    end

    #Fixup header helper methods, since we don't need all helpers
    def has_access?(uri, statuses=nil)
      current_user_has_access?(uri, statuses)
    end

    private

    def store_target_location
      session[:return_to] = request.original_url
    end

  end # end AuthenticationControllerHelper
end # end Secure
