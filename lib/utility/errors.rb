##
# <Rails.root>/lib/utility/exceptions.rb
#
# This module is included by Rails, and provide several
# custom exceptions for appropriate use.
#
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3.13.2013

module Utility
  module Errors
    class SecurityRoleNotImplementedError < SecurityError
    end
    class SecurityImplementionError < SecurityError
    end
    class InvalidCredentialError < SecurityError
    end
    class ExpiredCredentialError < SecurityError
    end
    class AuthenticationError < SecurityError
    end
    class AccessRegistryError < SecurityError
    end
    class NoRequestPresentError < StandardError
    end
    class NoConnectionAvailableError < StandardError
    end
    class NotFound < StandardError
    end
    class RemoteConnectionFailure < StandardError
    end
  end
end
