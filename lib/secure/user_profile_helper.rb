module Secure
  module UserProfileHelper
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

    def generate_unique_token(column)
      Rails.logger.debug "#{self.class.name}.#{__method__} called for #{username}'s #{column}"
      begin
        if  column.to_s.eql?("remember_token")
          self[column] = SecureRandom.urlsafe_base64
        else
          self[column] = users_store.generate_unique_key
        end
      end while User.exists?(column => self[column])
      true
    end

    def regenerate_remember_token!
      self.generate_unique_token(:remember_token)
      self[:remember_token_digest] = Secure::UserProfile.get_new_secure_digest(self[:remember_token])
    end

    # returns true/false if any <column>_digest matches token
    # note: Password.new(digest) decrypts digest
    def token_authentic?(token)
      self.attribute_names.select do |attr|
        attr.split("_").last.eql?("digest") ?
            BCrypt::Password.new(self[attr]).is_password?(token) : false
      end.any?    # any? returns true/false if any digest matched
    end

    def users_store
      Secure::ObjectStorageContainer.instance
    end

  end
end
