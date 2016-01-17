##
# lib/Secure/user_content_profile.rb
#
# Will Contain the users content profile
#
#
module Secure
  class UserProfile < Factory::ServicesBase

    include Secure::UserAccessProfile
    include Secure::UserContentProfile

    attr_accessor :id, :person_authenticated_key, :last_access

    # ActiveModel, ActiveRecord dynamic methods need delegation at a class level
      singleton_class.send :delegate, :find_by, :find_each, :where, :remember_token, :username, :to => ::User

    ##
    # Initialize with a user_object only
    def initialize(user)
        raise(Utility::Errors::NotFound, "UserProfile Requires a instance from the Users model.") if user.nil?
      @user_object = user
      @person_authenticated_key = user[:person_authenticated_key]
      @id = @user_object.id
      @last_access = Time.now
    end


    def active?
      @user_object.active and id.present?
    end

    def proxy_u
      @user_object
    end
    def proxy_c
      @user_object.class
    end

    # Authenticate returns self, we need to override that return value to return us instead
    #   user.authenticate('notright')      # => false
    #   user.authenticate('mUc3m00RsqyRe') # => user
    def authenticate(unencrypted_password)
        @user_object.authenticate(unencrypted_password) && self
    end

    # Warden will call this methods
    def disable_authentication_controls(prepare_only=false)
      self.last_access = Time.now
      proxy_u.save
      remove_from_store unless prepare_only
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      true
    end

    # Warden will call this methods
    def enable_authentication_controls(prepare_only=false)
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      self.last_access = Time.now
      self.setup_access_profile
      self.setup_content_profile

      add_to_store unless prepare_only
      return self if prepare_only
      true
    end


    # Support the regular respond_to? method by
    # answering for any attr that user_object actually handles
    #:nodoc:
    def respond_to_missing?(method, incl_private=false)
      @user_object.send(:respond_to_missing?, method, incl_private) || super(method,incl_private)
    end

    private

    # Easier to code than delegation, or forwarder
    def method_missing(method, *args, &block)
      if @user_object.respond_to?(method)
        block_given? ? @user_object.send(method, *args, block) :
            (args.size == 0 ?  @user_object.send(method) : @user_object.send(method, *args))
      else
        super(method, *args, &block)
      end
    end

    #
    # Wraps methods from Factory::ObjectStorageServices to apply our default key
    #

    # Saves user object to InMemory Container
    def add_to_store()
      set_existing_object(person_authenticated_key.to_sym, self)
    end

    # Removes saved user object from InMemory Container
    def remove_from_store()
      remove_existing_object(person_authenticated_key.to_sym)
    end

  end # end UserProfile
end # end Secure


# ["id",
#  "username",
#  "name",
#  "email",
#  "password_digest",
#  "remember_token",
#  "password_reset_token",
#  "password_reset_date",
#  "assigned_groups",
#  "roles",
#  "active",
#  "file_access_token",
#  "person_authenticated_key",
#  "assigned_roles",
#  "remember_token_digest",
#  "last_login"]
