## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object for DomainServices
# - Domain services live for one request cycle and are expensive to create, this object memotize them
# - This factory should be passed around like "factory" was
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory

class ServiceFactory

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


  # Support the regular respond_to? method by
  # answering for any attr that user_object actually handles
  #:nodoc:
  def respond_to_missing?(method, incl_private=false)
    @factory.send(:respond_to_missing?, method, incl_private) || super(method,incl_private)
  end


  protected
  FACTORY_PREFIX = 'ServiceFactory'.freeze

  # generate a new unique storage key
  def storage_generate_new_key
    object_store.generate_unique_key
  end
  # tests for keys existence
  def query_storage_key?(storage_key)
    object_store.has_storage_key?(storage_key, FACTORY_PREFIX)
  end
  # returns stored object
  def retrieve_storage_key(storage_key)
    object_store.get_stored_object(storage_key, FACTORY_PREFIX)
  end
  # Saves user object to InMemory Container
  def persist_storage_key(storage_key, obj)
    object_store.add_to_store(storage_key.to_sym, obj, FACTORY_PREFIX)
  end
  # Removes saved user object from InMemory Container
  def release_storage_key(storage_key)
    object_store.remove_from_store(storage_key.to_sym, FACTORY_PREFIX)
  end

  private

  ##
  # Object Storage Container
  # - keeps a reference to hold object in memory between requests
  def object_store
    Secure::ObjectStorageContainer.instance
  end

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