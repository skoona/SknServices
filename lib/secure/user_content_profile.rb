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
      result = self.instance_variable_get(:@content_profile) ||
          ((setup_content_profile and @content_profile.present?) ?
              self.instance_variable_get(:@content_profile) :
              Utility::ContentProfileBean.new({success: false, message: "No content profile data available for #{self.display_name}", entries:[]}))
      Rails.logger.debug("  #{self.name.to_s}.#{__method__}() returns: #{result.to_hash}")
      result
    end

    # Retrieves users content profile in ResultBean
    def setup_content_profile
      self.instance_variable_set(:@content_profile,
                                 ContentProfile.find_by_person_authentication_key(self.person_authenticated_key).
                                     try(:profile)
      )
      true
    end

    protected

  end # end UserContentProfile
end # end Secure
