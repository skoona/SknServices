##
# <Rails.root>/config/warden.rb
# Configures Warden to be user as a Rack level security manager
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3.13.2013
#
#
#  Refs: https://github.com/hassox/warden/wiki/Callbacks
#     ***http://pothibo.com/2013/07/authentication-with-warden-devise-less/
#        http://blog.maestrano.com/rails-api-authentication-with-warden-without-devise/
#        https://github.com/ajsharp/warden-rspec-rails
#        https://github.com/hassox/warden/wiki
#
#  Priamry Refs: http://pothibo.com/2013/07/authentication-with-warden-devise-less/
#                http://pothibo.com/2013/11/ruby-on-rails-inside-actiondispatch-and-rack/
#
# 'use Rack::Session::Cookie, :secret => "replace this with some secret key"'
##
# Main configuration
##
##
# OBJECTIVE:  Authenticate the user of every request !
#
# Allow Remember Me tokens to be used to sign in; prefer them over passwords
#
# This module along with the modules authentication_controller_helper, authentication_user_helper implement
# the desired security model with a minimum of impact on the ApplicationController[s] or UserProfile objects.
#
#
# CONTROLS:
# app/initializers/session_store set the Timeout of 30 minutes on Session Cookie (which is signed with domain)
# this file creates a permanent.signed remember_token with 8.hour expiration, set for http in dev, https(:secure) in production

# * When a cookie expires is is deleted by the browser, and never sent back
# * We intend for the session cookie to expire after 30 minutes, and have the token automatically sign them in again for
#   up to 8 hours.
# * Signing out deletes all cookies/tokens.  I.E. UserProfile is done using the system for a while.
#
# SEQUENCES: A
# deserialize() remember_token from session if session and/or keys exists
#   fetch() from UserProfiles UsersCache, set_user if found
#   after_failed_fetch() likely caused by invalid token, clear session cookies
# on_request() if user or excluded paths, then pass
#   if remember_token and no user, attempt warden.authenticate() with token, which will set_user
# ApplicationController#before_filter()  Redirect to SignIn if no user was set (save original to session)
#   SignIn get username/password then calls warden.authenticate() with credentials
#   Redirect to original Controller#Action or Pages#Home performed
# ** In either case when user is successfully set a callback:
#    on_authentication() is called which will add user to fetchable list
#
# SEQUENCES: B
# -- next request (user present)
# deserialize(), on_request(), controller#action, repeat until sign out(SEQUENCE C) or session-timeout(SEQUENCES: A)
#
# SEQUENCES: C
# -- SignOut
#   SignOut handled by Sessions#Destroy() and warden.logout()
#   logout causes callback: before_logout() to run and remove user from fetch cache and deletes all cookies
#
##
# DEBUG Legend:
#
# :01 RailsWarden:Manager
# :st serialize_into_session              using person_authenticated_key rather than user.id
# :sf serialize_from_session              retrieves memory object from object cache
#
# :pw Strategy :password                  set user and call after_auth, fail (if last) and call after_fetch_failed:event:authent
# :rt Strategy :remember_token
# :ba Strategy :http_basic_auth
# :na Strategy :not_authorized
#
# :or Callback :on_request                 Nothing
# :aa Callback :after_authentication       Establishes UserProfile caches, resolve roles, clear session-menu, checks last login, causes user.save
# :aff Callback :after_failed_fetch        if path.secure then DROPS both cookies, clears flash, issue "Please login..."
# :bf Callback :before_failure             DROPS remember_token, set REDIRECT :unauthenticated
# :bl Callback :before_logout              UserProfile cleanup, drops token and session, resets session
##

# env['warden'].authenticated?               # Ask the question if a request has been previously authenticated
# env['warden'].authenticated?(:foo)         # Ask the question if a request is authenticated for the :foo scope
# env['warden'].authenticate(:password)      # Try to authenticate via the :password strategy.  If it fails proceed anyway.
# env['warden'].authenticate!(:password)     # Ensure authentication via the password strategy. If it fails, bail.

# Warden.default_user_class = Secure::UserProfile
# Warden.unauthenticated_action = "unauthenticated"

Rails.application.config.middleware.insert_after ActionDispatch::Flash, Rack::Attack
Rails.application.config.middleware.insert_after Rack::Attack, Warden::Manager do |manager|
  # puts "===============[DEBUG]:01 #{self.class}\##{__method__}"
  manager.default_scope = :access_profile
  manager.default_strategies :api_auth, :remember_token, :password, :not_authorized
  manager.scope_defaults :access_profile,
                         :store => true,
                         :strategies => [:password, :not_authorized],
                         :action => :new
  manager.failure_app = lambda {|env| SessionsController.action(:unauthenticated).call(env) }
end


# RackSessionAccess config
if Rails.env.test?
  Rails.application.config.middleware.insert_before Warden::Manager, RackSessionAccess::Middleware
end

class Warden::SessionSerializer
  ##
  # Save the userProfile id to session store
  def serialize(record)
    [record.class.name, record.person_authenticated_key]
  end

  ##
  # Restore a klass name and id from session store
  # Use id to find the existing object
  def deserialize(keys)
    # puts "===============[DEBUG]:sf #{self.class}\##{__method__}"
    klass, pak = keys
    klass = case klass
              when Class
                klass
              when String, Symbol
                klass.to_s.classify.constantize
            end
    klass.fetch_cached_user( pak )
  end
end

# Todo: Create more of these specialty classes to wrap encodings
Warden::Strategies.add(:api_auth) do
  def auth
    @auth ||= Rack::Auth::Basic::Request.new(env)  # TODO: how long does this last, or for how many users?
  end

  def valid?
    # puts "===============[DEBUG]:ba #{self.class}\##{__method__}"
    auth.provided? && auth.basic? && auth.credentials
  end

  def authenticate!
    logger.debug "  -> Warden::Strategies.add(:api_auth).authenticate!()"
    user = Secure::UserProfile.find_and_authenticate_user(auth.credentials[0],auth.credentials[1])
    (user.present? and user.active?) ? success!(user, "Signed in successfully.  Basic") : fail("Your Credentials are invalid or expired. Invalid username or password!  Fail Basic")
  rescue => e
    fail("Your Credentials are invalid or expired.  Not Authorized! [ApiAuth](#{e.message})")
  end
end

##
# Use the remember_token from the requests cookies to authorize user
Warden::Strategies.add(:remember_token) do
  def valid?
    # puts "===============[DEBUG]:rt #{self.class}\##{__method__}"
    request.cookies["remember_token"].present?
  end

  def authenticate!
    Rails.logger.debug "  -> Warden::Strategies.add(:remember_token).authenticate!()"
    remember_token = request.cookies["remember_token"]
    token = Base64.decode64(remember_token.split('--').first)
    token = token[1..-2] if token[0] == '"'
    user = Secure::UserProfile.fetch_remembered_user(token)
    (user.present? and user.active?) ? success!(user, "Session successfully restored. Remembered!") : fail("Your session has expired. FailRemembered")
  rescue => e
    fail("Your Credentials are invalid or expired. Not Authorized! [RememberToken](#{e.message})")
  end
end

##
# Use the fields from the Signin page to authorize user
Warden::Strategies.add(:password) do
  def valid?
    # puts "===============[DEBUG]:pw #{self.class}\##{__method__}"
    return false if request.get?
    params["session"].has_key?("username") and params["session"].has_key?("password") and
        params["session"]["username"].present? and params["session"]["password"].present?
  end

  def authenticate!
    logger.debug "  -> Warden::Strategies.add(:password).authenticate!()"
    user = Secure::UserProfile.find_and_authenticate_user(params["session"]["username"], params["session"]["password"])
    (user and user.active?) ? success!(user, "Signed in successfully. Password") : fail!("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
  rescue => e
    fail!("Your Credentials are invalid or expired. [Password](#{e.message})")
  end
end

##
# This will always fail, and is used as the last option should prior options fail
Warden::Strategies.add(:not_authorized) do
  def valid?
    # puts "===============[DEBUG]:na #{self.class}\##{__method__}"
    true
  end

  def authenticate!
    logger.debug "  -> Warden::Strategies.add(:not_authorized).authenticate!()"
    fail!("Your Credentials are invalid or expired. Not Authorized! [NotAuthorized](FailNotAuthorized)")
  end
end

##
# IF NO CURRENT USER PRESENT
# if remember me token is present
#    attempt to authenticate using token, fail to signin page, else pass
Warden::Manager.on_request do |proxy|
  # puts "===============[DEBUG]:or #{self.class}\##{__method__}"
  proxy.logger.debug " Warden::Manager.on_request(ENTER) userId=#{proxy.user().name if proxy.user().present?}, token=#{proxy.cookies['remember_token'].present?}, path_info=#{proxy.env['PATH_INFO']}, session.keys=#{proxy.raw_session.keys}"
  timeout_flag = false
  bypass_flag = false
  remembered = false
  attempted_remember_flag = false
  full_path = proxy.env['PATH_INFO']
  uri = (full_path.present? and full_path.starts_with?('/')) ? full_path[1..-1] : full_path

  bypass_flag = ("/").eql?(full_path) ||
      SknSettings.security.public_pages.any? {|p| full_path.present? ? full_path.starts_with?(p) : false } ||
      Secure::AccessRegistry.security_check?(full_path) ||   #  '/signin'
      Secure::AccessRegistry.security_check?(uri)            #  'signin'

  remembered = proxy.request.cookies["remember_token"].present?

  # Mac browser often look for special apple icons in the root directory which cause routing errors
  # attempt to immediately respond to their icon request
  # throw :warden if proxy.env['PATH_INFO'] =~ /apple-touch-icon(-precomposed)?\.png/


  # Nothing really to do here, except check for timeouts and set last_login as if it were last_access (not changing it now)
  unless bypass_flag

    # If session has expired logout the user, unless remember cookie is still valid
    # Browser deletes cookies that have expired so remembered should be nil or false
    # #fetch cached user will make it inactive if login timer expires
    if proxy.user and !proxy.user.active?
      timeout_flag = true
      proxy.logout()
      proxy.request.flash[:alert] = "Your Session has Expired! [Warden](#on_request)"
    end

    # see if we can restore a session via API or RememberToken
    unless proxy.authenticated?
      attempted_remember_flag = true
      Rails.logger.debug " Warden::Manager.on_request(BeforeAuth)"
      proxy.authenticate(:api_auth, :remember_token)
    end

  end # end bypass

  proxy.logger.perf " Warden::Manager.on_request(EXIT) PublicPage=#{bypass_flag ? 'yes': 'no'}, TimedOut=#{timeout_flag ? 'yes': 'no'}, RememberToken=#{remembered ? 'yes': 'no'}, Attempted Restore=#{attempted_remember_flag ? 'yes': 'no'}, userId=#{proxy.user().name if proxy.user().present?}, path_info=#{full_path}, sessionId=#{proxy.request.session_options[:id]} RequestId=#{proxy.request.uuid}"
  true
end

##
# Set remember_token only after a signin, and verify last login window
#
# A callback hook set to run every time after a user is set.
# This callback is triggered the first time one of those two events happens
# during a request: :authentication, and :set_user (when manually set).
#
# after_authentication is just a wrapper to after_set_user, which is only invoked
# when the user is set through the authentication path. The options and yielded arguments
# are the same as in after_set_user.
# -- after_authentication --
Warden::Manager.after_set_user except: :fetch do |user,auth,opts|
  # puts "===============[DEBUG]:aa #{self.class}\##{__method__}"
  remember = false
  remember = user.remember_token

  # setup user for session and object caching, and resolve authorization groups/roles
  user.try(:enable_authentication_controls)

  # force reload of navigation menu, which re-authorizes it too
  # auth.request.params["session"]["navigation_menu"] = nil

  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  remembered_for = Secure::UserProfile.security_remember_time

  if remember
    if Rails.env.production?
      auth.cookies.signed[:remember_token] = { value: remember, domain: domain_part, expires: Secure::UserProfile.security_session_time, httponly: true, secure: true }
    else
      auth.cookies.signed[:remember_token] = { value: remember, domain: domain_part, expires: remembered_for , httponly: true }
    end
  else
    auth.cookies.delete :remember_token, domain: domain_part
  end
  auth.logger.debug %Q! Warden::Manager.after_authentication(ONLY, token=#{remember ? true : false}) user=#{user.name unless user.nil?}, RememberedFor=#{remembered_for} session.id=#{auth.request.session_options[:id]} !
  true
end


##
# A callback that runs if no user could be fetched, meaning there is now no user logged in.
# - cleanup no-good cookies, and maybe session
# - All attempts to auth have been tried (i.e. all valid strategies)
#
Warden::Manager.after_failed_fetch do |user,auth,opts|
  # puts "===============[DEBUG]:af #{self.class}\##{__method__}"
  auth.logger.debug " Warden::Manager.after_failed_fetch(ONLY) :remember_token present?(#{auth.cookies["remember_token"].present?}), opts=#{opts}, session.id=#{auth.request.session_options[:id]}"
  true
end

##
# Injects the :new action on SessionsController
#
# A callback that runs just prior to the failure application being called.
# This callback occurs after PATH_INFO has been modified for the failure (default /unauthenticated)
# In this callback you can mutate the environment as required by the failure application
# If a Rails controller were used for the failure_app for example, you would need to set request[:params][:action] = :unauthenticated
# Ref: https://github.com/hassox/warden/blob/master/lib/warden/hooks.rb
#
# UnAuthenticated action is to allow another login attempt, thus we allow it to flow to failure_app of SessionsController#new
#
Warden::Manager.before_failure do |env, opts|
  # puts "===============[DEBUG]:bf #{self.class}\##{__method__}"
  # env['warden'].request.params[:action] = opts[:action] || :unauthenticated
  # env['warden'].request.params[:warden_failure] = opts
  domain_part = ("." + env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  env['warden'].cookies.delete( :remember_token, domain: domain_part )
  env['warden'].cookies.delete( Rails.application.config.session_options[:key], domain: domain_part )
  env['warden'].request.reset_session
  env['warden'].logger.debug " Warden::Manager.before_failure(ONLY) path:#{env['PATH_INFO']}, session.id=#{env['warden'].request.session_options[:id]}"
  true
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  # puts "===============[DEBUG]:bl #{self.class}\##{__method__}"
  user.proxy_u.active = true if user
  session_id_before_reset = auth.request.session_options[:id]
  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  user.disable_authentication_controls unless user.nil?
  auth.cookies.delete( Rails.application.config.session_options[:key], domain: domain_part )
  auth.request.reset_session
  auth.request.flash[:notice] = opts[:message] if opts[:message]

  auth.logger.debug " Warden::Manager.before_logout(ONLY) user=#{user.name unless user.nil?}, opts=#{opts}, starting-session.id=#{session_id_before_reset}, ending-session.id=#{auth.request.session_options[:id]}"
  true
end


##
# Warden Overrides related to Rails environment.
#
# Credit to and Influenced by:
#   https://github.com/hassox/rails_warden
#   https://github.com/plataformatec/devise/blob/master/lib/devise/rails/warden_compat.rb

module Warden::Mixins::Common

  # # Gets the rails request object by default if it's available
  def request
    return @request if @request
    if defined?(ActionDispatch::Request)
      @request = ActionDispatch::Request.new(env)
    elsif env['action_controller.rescue.request']
      @request = env['action_controller.rescue.request']
    else
      Rack::Request.new(env)
    end
  end

  def response
    return @response if @response
    if defined?(ActionDispatch::Response)
      @response  = ActionDispatch::Response.new
    elsif env['action_controller.rescue.response']
      @response = env['action_controller.rescue.response']
    else
      Rack::Response.new(env)
    end
  end

  def cookies
    unless defined?('ActionController::Cookies')
      puts 'cookies was not defined'
      return
    end
    @cookies ||= begin
                   # Duck typing...
      controller = Struct.new(:request, :response) do
        def self.helper_method(*args); end
      end
      controller.send(:include, ActionController::Cookies)
      controller.new(self.request, self.response).send(:cookies)
    end
  end

  def logger
    @_warden_logger ||= Logging.logger['WAR']
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

end # end common

module Secure
  module Warden
    module HelperMethods
      # The main accessor for the warden proxy instance
      # :api: public
      def warden
        request.env['warden']
      end

      # Proxy to the authenticated? method on warden
      # :api: public
      def authenticated?(*args)
        warden.authenticated?(*args)
      end
      alias_method :logged_in?, :authenticated?

      # Access the currently logged in user
      # :api: public
      def user(*args)
        warden.user(*args)
      end
      alias_method :current_user, :user

      def user=(user)
        warden.set_user user
      end
      alias_method :current_user=, :user=
    end # Helper Methods

    module ControllerOnlyMethods
      # Logout the current user
      # :api: public
      def logout(*args)
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(*args)
      end

      # Proxy to the authenticate method on warden
      # :api: public
      def authenticate(*args)
        warden.authenticate(*args)
      end

      # Proxy to the authenticate method on warden
      # :api: public
      def authenticate!(*args)
        defaults = {:action => :unauthenticated}
        if args.last.is_a? Hash
          args[-1] = defaults.merge(args.last)
        else
          args << defaults
        end
        warden.authenticate!(*args)
      end

    end
  end
end

Rails.configuration.after_initialize do
  class ::ActionController::Base
    include Secure::Warden::HelperMethods
    include Secure::Warden::ControllerOnlyMethods
  end

  module ::ApplicationHelper
    include Secure::Warden::HelperMethods
  end
end
