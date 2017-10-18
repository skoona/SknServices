##
#
# Emulates an ActionController for testing
#
#   let(:mc) {ServiceRegistryMockController.new(user: user)}
#   let(:service_registry)  { ServiceRegistry.new({registry: mc}) }


class ServiceRegistryMockController

  attr_accessor :registry, :controller_name, :action_name, :params, :user

  def initialize(params)
    params.keys.each do |k|
      instance_variable_set "@#{k.to_s}".to_sym, nil
      instance_variable_set "@#{k.to_s}".to_sym, params[k]
    end
    @user = params.fetch(:user, nil) unless @user
    @registry = params.fetch(:registry, nil) unless @registry
    @controller_name = params.fetch(:controller_name, 'testing')
    @action_name = params.fetch(:action_name, 'test')
  end

  def self.helper_method(values)
    # mock controller methods
  end
  def self.before_action(values)
    # mock controller methods
  end

  # Mock those methods you know will be called on the controller
  def controller
    self
  end

  def pg_info
    @pg_info
  end

  def current_user
    @user
  end

  def current_user=(u)
    @user = u
  end

  def session
    @sess ||= {}
  end

  def page_action_paths(paths)
    @paths ||= "/profiles/api_accessible_content.json?id=content"
  end

  def page_action_paths=(paths)
    @paths = paths
  end

  # called from a engine to check access with status
  def current_user_has_access?(uri, options=nil)
    opts = options || current_user.try(:user_options) || nil
    current_user.present? and current_user.has_access?(uri, opts)
  end
  # called from a engine to check access with status
  def current_user_has_create?(uri, options=nil)
    opts = options || current_user.try(:user_options) || nil
    current_user.present? and current_user.has_create?(uri, opts)
  end
  # called from a engine to check access with status
  def current_user_has_read?(uri, options=nil)
    opts = options || current_user.try(:user_options) || nil
    current_user.present? and current_user.has_read?(uri, opts)
  end
  # called from a engine to check access with status
  def current_user_has_update?(uri, options=nil)
    opts = options || current_user.try(:user_options) || nil
    current_user.present? and current_user.has_update?(uri, opts)
  end
  # called from a engine to check access with status
  def current_user_has_delete?(uri, options=nil)
    opts = options || current_user.try(:user_options) || nil
    current_user.present? and current_user.has_delete?(uri, opts)
  end


private

  def method_missing(method, *args, &block)
    Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
    if @registry.public_methods.include?(method)
      block_given? ? @registry.send(method, *args, block) :
          (args.size == 0 ?  @registry.send(method) : @registry.send(method, *args))
    else
      super
    end
  end

end