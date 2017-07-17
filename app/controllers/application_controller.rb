##
#
#

class ApplicationController < ActionController::Base
  include Factory::ControllerMethods                 # Development Strategy
  include ApplicationHelper                          # Controller, View Helper
  include Secure::ControllerAccessControl            # Warden Security

end
