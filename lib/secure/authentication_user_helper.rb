# lib/Secure/authentication_user_helper.rb
#
# uses the ObjectStorageContainer to hold user object that are logged in
# - remember_token is used as the storage key
#
module Secure
  module AuthenticationUserHelper
    extend ActiveSupport::Concern

    included do
      #raise Utility::Errors::SecurityImplementionError, "You must have a remember_token defined for use as the key to storage!" unless self.respond_to?(:remember_token)
    end

    module ClassMethods
      # find user from our internal list
      def fetch_existing_user (token=nil)
        value = users_store.get_stored_object(token)
        value = self.find_by_remember_token(token) unless value.present? or token.nil?
        Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{token}) cache size =>#{users_store.size_of_store}, returns #{value.present? ? value.name : 'Not Found!'}")
        value
      end

      def logout(token)
        user_object = users_store.get_stored_object(token.to_sym)
        user_object.disable_authentication_controls if user_object.present?
      end

      def get_new_secure_digest(token)
        BCrypt::Password.create(token, (BCrypt::Engine::MIN_COST + Settings.security.extra_digest_strength)) # Good and Strong
      end

      def get_new_secure_token
        SecureRandom.urlsafe_base64
      end

      # TODO: Get a Token
      #   rememberme_token = User.get_new_secure_token()
      # TODO: Persist the Token as an encrypted digest
      #   update_attribute(:remember_digest, User.get_new_secure_digest(rememberme_token))
      # TODO: Authenticate the Token against its Digest
      #   User.is_token_authentic?(digest,token)


      def users_store
        Secure::ObjectStorageContainer.instance
      end
    end

    # returns true/false if any <column> digest matches token
    # note: Password.new(digest) decrypts digest
    def is_token_authentic?(token)
      attribute_names.select do |attr|
        attr.split("_").last.eql?("digest") ?
            BCrypt::Password.new(attr).is_password?(token) : false
      end.any?    # any? returns true/false if any digest matched
    end

    # Warden will call this methods
    def disable_authentication_controls
      remove_from_store
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) ")
    end

    # Warden will call this methods
    def enable_authentication_controls
      add_to_store
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) ")
    end

    protected

    def add_to_store()
      Secure::ObjectStorageContainer.instance.add_to_store(remember_token, self)
    end

    def remove_from_store()
      Secure::ObjectStorageContainer.instance.remove_from_store remember_token
    end
  end # end AuthenticationUserHelper
end # end Secure
