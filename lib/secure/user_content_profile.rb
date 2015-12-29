##
# lib/Secure/user_content_profile.rb
#
# Will Contain the users content profile
#
#
module Secure
  module UserContentProfile
    extend ActiveSupport::Concern

    included do
      # Todo: Breaks Test User for now
      # raise Utility::Errors::SecurityImplementionError,
      #       "You are missing a critical security var: :person_authenticated_key; Please implement!" unless
      #     self.attribute_names.include?("person_authenticated_key")
    end

    module ClassMethods

    end

    #
    # Instance Methods
    #
    # Returns RB of ContentProfile
    def content_profile
      self.instance_variable_get(:@content_profile)
    end

    # Retrieves users content profile in ResultBean
    def setup_content_profile
      self.instance_variable_set(:@content_profile,
                                 ContentProfile.find_by_person_authentication_key(self.person_authenticated_key).
                                     try(:profile)
      )
    end

    protected

  end # end UserContentProfile
end # end Secure
