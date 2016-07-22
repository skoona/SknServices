## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object for DomainsBase
# - Domain services live for one request cycle and are expensive to create, this object memorizes them
# - This factory should be passed around like "factory"
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory
class ServiceFactory < ::Factory::ServicesBase

  attr_accessor :factory

  def initialize(params={})
    @factory = params[:factory]
    @user = @factory.current_user unless @factory.nil?
    raise ArgumentError, "ServiceFactory: Missing required initialization param!" if @factory.nil?
  end

  def password_service
    @sf_password_service ||= ::PasswordService.new({factory: self})
    yield @sf_password_service if block_given?
    @sf_password_service
  end
  def profile_data_services
    @sf_profile_data_services ||= ::ProfileDataServices.new({factory: self})
    yield @ctprofile_data_services if block_given?
    @sf_profile_data_services
  end
  def access_profile_service
    @sf_access_profile_service ||= ::AccessProfileService.new({factory: self})
    yield @sf_access_profile_service if block_given?
    @sf_access_profile_service
  end
  def content_profile_service
    @sf_content_profile_service ||= ::ContentProfileService.new({factory: self})
    yield @sf_content_profile_service if block_given?
    @sf_content_profile_service
  end
  def profile_builder
    @sf_profile_builder ||= Builder::ProfileBuilder.new({factory: self})
    yield @sf_profile_builder if block_given?
    @sf_profile_builder
  end
  def content_adapter_file_system
    @sf_content_adapter_file_system ||= Builder::FileSystemAdapter.new({factory: self})
    yield @sf_content_adapter_file_system if block_given?
    @sf_content_adapter_file_system
  end
  def content_adapter_inline_values
    @sf_content_adapter_inline_values ||= Builder::InlineValuesAdapter.new({factory: self})
    yield @sf_content_adapter_inline_values if block_given?
    @sf_content_adapter_inline_values
  end

  ##
  # Adapter by Content
  # Will accepts ResultBean, Hash, ot single string value
  def adapter_for_content_profile_entry(content)
    content_type = (content.respond_to?(:to_hash) ? content['content_type'] : content)
    case content_type
      when "Commission", "Activity"
        content_adapter_file_system
      when "Notification", "Operations"
        content_adapter_inline_values
      else
        content_adapter_file_system # default for now
    end
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
  def get_session_param(key)
    @factory.session[key]
  end
  def set_session_param(key, value)
    @factory.session[key] = value
  end

  protected

  # Support the regular respond_to? method by
  # answering for any attr that user_object actually handles
  #:nodoc:
  def respond_to_missing?(method, incl_private=false)
    @factory.send(:respond_to?, method) || super(method,incl_private)
  end


  private

  # Easier to code than delegation, or forwarder; @factory assumed to equal @controller
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