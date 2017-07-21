module Secure
  module UserProfileHelper

    def self.included(klass)
      Rails.logger.debug("#{self.name} included By #{klass.name}")
      # raise Utility::Errors::SecurityImplementionError,
      #       "You are missing one or more critical security fields; Please implement!" unless
      #       self.attribute_names.include?("person_authenticated_key") and
      #       self.attribute_names.include?("assigned_groups") and
      #       self.attribute_names.include?("assigned_roles") and
      #       self.attribute_names.include?("user_options") and
      #       self.attribute_names.include?("username") and
      #       self.attribute_names.include?("roles")
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
          self[column] = Secure::ObjectStorageContainer.instance.generate_unique_key
        end
      end while User.exists?(column => self[column])
      true
    end

    def regenerate_remember_token!
      self.generate_unique_token(:remember_token)
      self[:remember_token_digest] = BCrypt::Password.create(self[:remember_token],
                                                             cost: (BCrypt::Engine::MIN_COST + SknSettings.security.extra_digest_strength)) # Good and Strong
    end

    # returns true/false if any <column>_digest matches token
    # note: Password.new(digest) decrypts digest
    def token_authentic?(token)
      rcode = self.attribute_names.select do |attr|
        attr.split("_").last.eql?("digest") ?
            BCrypt::Password.new(self[attr]).is_password?(token) : false
      end.any?    # any? returns true/false if any digest matched
      Rails.logger.debug "  #{self.class.name}.#{__method__} called for #{username}'s Token Valid=#{rcode}"
      rcode
    end

  end
end
