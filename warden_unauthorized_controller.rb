##
# app/controllers/warden_unauthorized_controller.rb
# ref: http://blog.maestrano.com/rails-api-authentication-with-warden-without-devise/
#  -- manager.failure_app = UnauthorizedController
#
class WardenUnauthorizedController < ActionController::Metal
  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    self.response_body = "Unauthorized Action"
    self.status = :unauthorized
  end
end