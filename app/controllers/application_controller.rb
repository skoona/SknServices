##
#
#

class ApplicationController < ActionController::Base
  include Registry::ControllerMethods                 # Development Strategy
  include ApplicationHelper                          # Controller, View Helper
  include Secure::ControllerAccessControl            # Warden Security

end
