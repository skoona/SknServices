##
# lib/Secure/user_content_profile.rb
#
# Will Contain the users content profile
#
#
module Secure
  class UserProfile < Factory::ServicesBase

    include Secure::UserAccessControl

    attr_accessor :id, :person_authenticated_key, :last_access, :name, :user_options,
                  :assigned_groups, :assigned_roles, :username, :email, :roles

    # ActiveModel, ActiveRecord dynamic methods need delegation at a class level
    singleton_class.send :delegate, :find_by, :find_each, :where, :to => ::User


    ##
    # Initialize with a user_object only
    def initialize(user)
      raise(Utility::Errors::NotFound, "UserProfile Requires a instance from the Users model.") if user.nil?

      @user_object = user
      @last_access = Time.now

      # @id = user.id

      [:@id, :@person_authenticated_key, :@assigned_roles,
       :@name, :@user_options, :@assigned_groups, :@username,
       :@email, :@roles].each do |k|
        instance_variable_set(k, nil)
        instance_variable_set(k, user.send(k.to_s[1..-1].to_sym) )
      end

      setup_combined_user_roles()
    end

    def proxy_u
      @user_object
    end
    def proxy_c
      proxy_u.class
    end

    def active?
      proxy_u.active and id.present?
    end

    def display_name
      @name
    end

    def remember_token
      proxy_u.remember_token
    end

    # Authenticate returns self, we need to override that return value to return us instead
    #   user.authenticate('notright')      # => false
    #   user.authenticate('mUc3m00RsqyRe') # => user
    def authenticate(unencrypted_password)
        proxy_u.authenticate(unencrypted_password) && self
    end

    # Warden will call this methods
    def disable_authentication_controls(prepare_only=false)
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      self.last_access = Time.now
      remove_existing_object(person_authenticated_key.to_sym)
      true
    end

    # Warden will call this methods
    def enable_authentication_controls(prepare_only=false)
      Rails.logger.debug("  #{self.class.name.to_s}.#{__method__}(#{name}) Token=#{person_authenticated_key}")
      return self if prepare_only
      self.last_access = Time.now
      set_existing_object(person_authenticated_key.to_sym, self)
      true
    end

    # Unpack Groups and Combine with assigned, into roles
    # Called during Initialization
    def setup_combined_user_roles
      Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{@combined_user_roles.present? ? 'True' : 'False'})")
      return @combined_user_roles if @combined_user_roles.present?
      rc = false
      role = []
      role = assigned_groups.map do |rg|
        UserGroupRole.list_user_roles(rg)
      end
      if role.present?
        role += assigned_roles
        role += assigned_groups
        @combined_user_roles = roles = role.flatten.uniq
        rc = true
      end
      Rails.logger.debug("  #{self.name.to_s}.#{__method__}(#{@combined_user_roles.present? ? 'True' : 'False'}) Persisted=#{rc} #{}Roles=#{@combined_user_roles.length}")
      rc
    end

    # Return all Roles
    def combined_access_roles
      @combined_user_roles ||= (roles || [])
    end


    # Support the regular respond_to? method by
    # answering for any attr that user_object actually handles
    #:nodoc:
    def respond_to_missing?(method, incl_private=false)
      proxy_u.send(:respond_to?, method) || super(method,incl_private)
    end

    private

    # Easier to code than delegation, or forwarder
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method.to_s}")
      # puts("  #{self.name.to_s}.#{__method__} looking for: #{method.to_s}")   # ToDo: No internal methods (__method__) in method missing
      # puts("  UserProfile#method_missing() looking for: #{method.to_s}")

      if proxy_u.respond_to?(method)
        block_given? ? proxy_u.send(method, *args, block) :
            (args.size == 0 ?  proxy_u.send(method) : proxy_u.send(method, *args))
      else
        super(method, *args, &block)
      end
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
# ]
