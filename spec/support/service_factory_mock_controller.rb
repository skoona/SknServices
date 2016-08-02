##
#
# Emulates an ActionController for testing
#
#   let(:mc) {ServiceFactoryMockController.new(user: user)}
#   let(:service_factory)  { ServiceFactory.new({factory: mc}) }


class ServiceFactoryMockController

  attr_accessor :factory, :controller_name, :action_name, :params

  def initialize(params)
    params.keys.each do |k|
      instance_variable_set "@#{k.to_s}".to_sym, nil
      instance_variable_set "@#{k.to_s}".to_sym, params[k]
    end
    @user = params.fetch(:user, nil) unless @user
    @factory = params.fetch(:factory, nil) unless @factory
    @controller_name = params.fetch(:controller_name, nil)
    @action_name = params.fetch(:action_name, nil)
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


  private
  def method_missing(method, *args, &block)
    Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
    if @factory.respond_to?(method)
      block_given? ? @factory.send(method, *args, block) :
          (args.size == 0 ?  @factory.send(method) : @factory.send(method, *args))
    else
      super(method, *args, &block)
    end
  end

end