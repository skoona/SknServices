## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object for DomainsBase
# - Domain services live for one request cycle and are expensive to create, this object memotizes them
# - This factory should be passed around like "factory"
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory

class ServiceFactory < ::Factory::ServicesBase

  attr_accessor :factory

  def initialize(params={})
    @factory = params[:factory] || params[:controller]
    @user = @factory.current_user unless @factory.nil?
    raise ArgumentError, "ServiceFactory: Missing required initialization param!" if @factory.nil?
  end


  def password_service
    @ct_password_service ||= ::PasswordService.new({factory: self})
    yield @ct_password_service if block_given?
    @ct_password_service
  end
  def access_profile_service
    @ct_access_profile_service ||= ::AccessProfileService.new({factory: self})
    yield @ct_access_profile_service if block_given?
    @ct_access_profile_service
  end
  def content_profile_service
    @ct_content_profile_service ||= ::ContentProfileService.new({factory: self})
    yield @ct_content_profile_service if block_given?
    @ct_content_profile_service
  end


  ##
  # The controller knows itself as 'self'
  # so we bridge to it for our Services
  def controller
    @factory
  end

  ##
  # Same for current_user, a controller value
  def current_user
    @user ||= @factory.current_user
  end

  # User Session Handler
  def get_session_params(key)
    @factory.session[key]
  end
  def set_session_params(key, value)
    @factory.session[key] = value
  end

  protected

  # Support the regular respond_to? method by
  # answering for any attr that user_object actually handles
  #:nodoc:
  def respond_to_missing?(method, incl_private=false)
    @factory.send(:respond_to_missing?, method, incl_private) || super(method,incl_private)
  end


  private

  # Easier to code than delegation, or forwarder
  def method_missing(method, *args, &block)
    if @factory.respond_to?(method)
      block_given? ? @factory.send(method, *args, block) :
          (args.size == 0 ?  @factory.send(method) : @factory.send(method, *args))
    else
      super(method, *args, &block)
    end
  end

end