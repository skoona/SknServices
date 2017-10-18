##
#
#

class ApplicationController < ActionController::Base
  include Registry::RegistryMethods                 # Development Strategy & Response Wrappers
  include ApplicationHelper                         # Controller, View Helper
  include Secure::AccessAuthenticationMethods       # Warden Security


  # Enhance the PERF Logger output
  # see: config/initializers/notification_logger.rb
  def append_info_to_payload(payload)
    super
    payload[:session_id] = request.session_options[:id] || 'na'
    payload[:uuid] = request.uuid || 'na'
    payload[:username] = current_user.present? ? current_user.username :  'no-user'
  end

end
