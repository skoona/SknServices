##
#
#

class ApplicationController < ActionController::Base
  include Registry::RegistryMethods                 # Development Strategy
  include ApplicationHelper                          # Controller, View Helper
  include Secure::AccessAuthenticationMethods            # Warden Security

end
