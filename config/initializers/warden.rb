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
# :aa Callback :after_authentication       Establishs UserProfile caches, resolve roles, clear session-menu, checks last login, causes user.save
# :aff Callback :after_failed_fetch        if path.secure then DROPS both cookies, clears flash, issue "Please login..."
# :bf Callback :before_failure             DROPS remember_token, set REDIRECT :unauthenticated
# :bl Callback :before_logout              UserProfile cleanup, drops token and session, resets session
##

# env['warden'].authenticated?               # Ask the question if a request has been previously authenticated
# env['warden'].authenticated?(:foo)         # Ask the question if a request is authenticated for the :foo scope
# env['warden'].authenticate(:password)      # Try to authenticate via the :password strategy.  If it fails proceed anyway.
# env['warden'].authenticate!(:password)     # Ensure authentication via the password strategy. If it fails, bail.

# Rails.application.config.middleware.use Warden::Manager do |manager|
# Rails.application.config.middleware.insert_after ActionDispatch::ParamsParser, RailsWarden::Manager do |manager|
Rails.application.config.middleware.insert_after ActionDispatch::ParamsParser, RailsWarden::Manager do |manager|
  # puts "===============[DEBUG]:01 #{self.class}\##{__method__}"
  # manager.default_user_class = Secure::UserProfile
  # manager.unauthenticated_action = "unauthenticated"
  manager.default_scope = :access_profile
  manager.default_strategies :remember_token, :password, :http_basic_auth, :not_authorized
  manager.scope_defaults :access_profile,
                         :store => true,
                         :strategies => [:remember_token, :password, :http_basic_auth, :not_authorized],
                         :action => :new
  manager.failure_app = lambda {|env| SessionsController.action(:new).call(env) }

  # otherwise wrap class Warden::SessionSerializer, def serialize(record); def deserialize(keys)
  manager.serialize_into_session do |record|
    # puts "===============[DEBUG]:st #{self.class}\##{__method__}"
    [record.class.name, record.person_authenticated_key]
  end
  manager.serialize_from_session do |keys|
    # puts "===============[DEBUG]:sf #{self.class}\##{__method__}"
    klass, token = keys
    klass = case klass
              when Class
                klass
              when String, Symbol
                klass.to_s.classify.constantize
            end
    user = klass.fetch_cached_user( token )
    user
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
    user = Secure::UserProfile.find_and_authenticate_user(params["session"]["username"], params["session"]["password"])
    (user and user.active?) ? success!(user, "Signed in successfully. Password") : fail!("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
  rescue
    fail!("Your Credentials are invalid or expired. RescuePassword")
  end
end

##
# Use the remember_token from the requests cookies to authorize user
Warden::Strategies.add(:remember_token) do
  def valid?
    return false if request.get?
    # puts "===============[DEBUG]:rt #{self.class}\##{__method__}"
    request.cookies["remember_token"].present?
  end

  def authenticate!
    remember_token = request.cookies["remember_token"]
    token = Marshal.load(Base64.decode64(CGI.unescape(remember_token.split("\n").join).split('--').first)) if remember_token
    user = Secure::UserProfile.fetch_remembered_user(token)
    (user.present? and user.active?) ? success!(user, "Signed in successfully. Remembered!") : fail("Your Credentials are invalid or expired. FailRemembered")
  rescue
    fail("Your Credentials are invalid or expired. Not Authorized! RescueRemembered")
  end
end

Warden::Strategies.add(:http_basic_auth) do
  def auth
    @auth ||= Rack::Auth::Basic::Request.new(env)  # TODO: how long does this last, or for how many users?
  end

  def valid?
    return false if request.get?
    # puts "===============[DEBUG]:ba #{self.class}\##{__method__}"
    auth.provided? && auth.basic? && auth.credentials
  end

  def authenticate!
    user = Secure::UserProfile.find_and_authenticate_user(auth.credentials[0],auth.credentials[1])
    (user.present? and user.active?) ? success!(user, "Signed in successfully.  Basic") : fail("Your Credentials are invalid or expired. Invalid username or password!  Fail Basic")
   rescue
    fail("Your Credentials are invalid or expired.  Not Authorized! RescueBasic")
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
    fail!("Your Credentials are invalid or expired. Not Authorized! FailNotAuthorized")
  end
end

##
# IF NO CURRENT USER PRESENT
# if remember me token is present
#    attempt to authenticate using token, fail to signin page, else pass
Warden::Manager.on_request do |proxy|
  # puts "===============[DEBUG]:or #{self.class}\##{__method__}"
  Rails.logger.debug " Warden::Manager.on_request(ENTER) userId=#{proxy.user().name if proxy.user().present?}, token=#{proxy.cookies['remember_token'].present?}, original_fullpath=#{proxy.request.original_fullpath}, session.keys=#{proxy.raw_session.keys}"
  timeout_flag = false

  # Nothing really to do here, except check for timeouts and set last_login as if it were last_access (not changing it now)
  user_object = proxy.user()
  if user_object.present? && Secure::UserProfile.last_login_time_expired?(user_object)
    proxy.logout()
    proxy.request.flash[:alert] = ["Session Expired! Please Sign In To Continue.  Warden.on_request"]
    timeout_flag = true
  end

  Rails.logger.debug " Warden::Manager.on_request(EXIT) timeout=#{timeout_flag}, userId=#{proxy.user().name if proxy.user().present?}, token=#{proxy.cookies['remember_token'].present?}, path_info=#{proxy.request.fullpath}, sessionId=#{proxy.request.session_options[:id]}"
end

##
# Set remember_token only after a signin, and verify last login window
#
# A callback hook set to run every time after a user is set.
# This callback is triggered the first time one of those three events happens
# during a request: :authentication, :fetch (from session) and :set_user (when manually set).
#
# after_authentication is just a wrapper to after_set_user, which is only invoked
# when the user is set through the authentication path. The options and yielded arguments
# are the same as in after_set_user.
# -- after_authentication --
Warden::Manager.after_set_user except: :fetch do |user,auth,opts|
  # puts "===============[DEBUG]:aa #{self.class}\##{__method__}"
  remember = false
  remember = true if auth.request.params.key?("session") && "1".eql?(auth.request.params["session"]["remember_me_token"])

  # setup user for session and object caching, and resolve authorization groups/roles
  user.enable_authentication_controls

  # force reload of navigation menu, which re-authorizes it too
  # auth.request.params["session"]["navigation_menu"] = nil

  if remember
    if Rails.env.production?
      auth.cookies.permanent.signed[:remember_token] = { value: user.remember_token, domain: auth.env["SERVER_NAME"], expires: Settings.security.session_expires, httponly: true, secure: true }
    else
      auth.cookies.permanent.signed[:remember_token] = { value: user.remember_token, domain: auth.env["SERVER_NAME"], expires: Settings.security.remembered_for, httponly: true }
    end
  else
    auth.cookies.delete :remember_token, domain: auth.env["SERVER_NAME"]
  end
  Rails.logger.debug %Q! Warden::Manager.after_authentication(ONLY, token=#{remember ? true : false}) user=#{user.name unless user.nil?}, Host=#{auth.env["SERVER_NAME"]}, session.id=#{auth.request.session_options[:id]} !
end


##
# A callback that runs if no user could be fetched, meaning there is now no user logged in.
# - cleanup no-good cookies, and maybe session
# - All attempts to auth have been tried (i.e. all valid strategies)
#
Warden::Manager.after_failed_fetch do |user,auth,opts|
  # puts "===============[DEBUG]:af #{self.class}\##{__method__}"
  full_path = auth.request.original_fullpath
  bypass = full_path.eql?("/") ||
      Settings.security.public_pages.map {|p| full_path.include?(p) }.any? ||
      Secure::AccessRegistry.security_check?(full_path)

    unless bypass    # Controllers's login_required? will sort this out
      auth.request.flash[:notice] = "Please sign in to continue. No user logged in!   Warden.after_fetch_failed"
      auth.cookies.delete '_SknServices_session'.to_sym, domain: auth.env["SERVER_NAME"]
      # auth.cookies.delete :remember_token, domain: auth.env["SERVER_NAME"]
    end

  Rails.logger.debug " Warden::Manager.after_failed_fetch(bypass:#{bypass}:#{full_path}) remember_token present?(#{auth.cookies["remember_token"].present?}), opts=#{opts}, user=#{auth.user().name unless user.nil?}, session.id=#{auth.request.session_options[:id]}"
end

##
# Injects the home action to match SessionsController
#
# A callback that runs just prior to the failure application being called.
# This callback occurs after PATH_INFO has been modified for the failure (default /unauthenticated)
# In this callback you can mutate the environment as required by the failure application
# If a Rails controller were used for the failure_app for example, you would need to set request[:params][:action] = :unauthenticated
# Ref: https://github.com/hassox/warden/blob/master/lib/warden/hooks.rb
#
Warden::Manager.before_failure do |env, opts|
  # puts "===============[DEBUG]:bf #{self.class}\##{__method__}"
  full_path = env['warden'].request.original_fullpath
  bypass = full_path.eql?("/") ||
      Settings.security.public_pages.map {|p| full_path.include?(p) }.any? ||
      Secure::AccessRegistry.security_check?(full_path)

  Rails.logger.debug " Warden::Manager.before_failure(bypass:#{bypass}:#{full_path}) session.id=#{env['warden'].request.session_options[:id]}"
  env['warden'].cookies.delete :remember_token, domain: env["SERVER_NAME"]
  unless bypass
    params = Rack::Request.new(env).params
    params[:action] = :new
    params[:warden_failure] = opts
  end
  # env['action_dispatch.request.path_parameters'][:action] = :new unless bypass
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  # puts "===============[DEBUG]:bl #{self.class}\##{__method__}"
  user.disable_authentication_controls unless user.nil?
  auth.cookies.delete '_SknServices_session'.to_sym, domain: auth.env["SERVER_NAME"]
  auth.cookies.delete :remember_token, domain: auth.env["SERVER_NAME"]
  auth.reset_session!
  auth.request.flash[:notice] = opts[:message] if opts[:message]

  Rails.logger.debug " Warden::Manager.before_logout(ONLY) user=#{user.name unless user.nil?}, opts=#{opts}, Host=#{auth.env["SERVER_NAME"]}, session.id=#{auth.request.session_options[:id]}"
end
