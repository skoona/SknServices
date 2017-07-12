
# https://github.com/plataformatec/devise/blob/master/lib/devise/rails/warden_compat.rb

module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end
end




# routes.rb
# restricts available routes to public
scope constraints: lambda { |r| r.env['warden'].user.nil?} do
  get "signup", to: "users#new", as: "signup"
  get "login", to: "sessions#new", as: "login"
  # other public paths
end

# http://railscasts.com/episodes/305-authentication-with-warden?view=asciicast
# config/initializers/warden.rb
Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
end


#  If we call authenticate! (with a exclamation mark) the failure application will be triggered whenever authentication fails. This means that we can simplify the action’s code.
# sessions_controller.rb
class SessionsController < ActionController::Base

  def new
    flash.now.alert = warden.message if warden.message.present?
  end

  def create
    warden.authenticate!
    redirect_to root_url, notice: "Logged in!"
  end

  def destroy
    warden.logout
    redirect_to root_url, notice: "Logged out!"
  end

end

class ApplicationController < ActionController::Base

  private

  def current_user
    warden.user
  end
  helper_method :current_user

  def warden
    env['warden']
  end

end