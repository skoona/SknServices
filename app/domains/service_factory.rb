## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object from DomainsBase
# - Domain services live for one request cycle and are expensive to create, this object memorizes them
# - This factory should be passed around like "factory" or "service"
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory
class ServiceFactory < ::Factory::FactoriesBase


  ##
  # Application Services used in Controller methods
  ##

  def access_service
    def self.access_service
      yield @sf_access_service if block_given?
      @sf_access_service
    end
    @sf_access_service = ::AccessService.new({factory: self})
    yield @sf_access_service if block_given?
    @sf_access_service
  end
  def content_service
    def self.content_service
      yield @sf_content_service if block_given?
      @sf_content_service
    end
    @sf_content_service = ::ContentService.new({factory: self})
    yield @sf_content_service if block_given?
    @sf_content_service
  end

  ##
  # Content Providers
  ##

  def xml_profile_provider
    def self.xml_profile_provider
      yield @sf_xml_profile_builder if block_given?
      @sf_xml_profile_builder
    end
    @sf_xml_profile_builder = Providers::XMLProfileProvider.new({factory: self})
    yield @sf_xml_profile_builder if block_given?
    @sf_xml_profile_builder
  end
  def db_profile_provider
    def self.db_profile_provider
      yield @sf_db_profile_builder if block_given?
      @sf_db_profile_builder
    end
    @sf_db_profile_builder = Providers::DBProfileProvider.new({factory: self})
    yield @sf_db_profile_builder if block_given?
    @sf_db_profile_builder
  end

  ##
  # Content Adapters
  ##

  def content_adapter_file_system
    def self.content_adapter_file_system
      yield @sf_content_adapter_file_system if block_given?
      @sf_content_adapter_file_system
    end
    @sf_content_adapter_file_system = Providers::FileSystemAdapter.new({factory: self})
    yield @sf_content_adapter_file_system if block_given?
    @sf_content_adapter_file_system
  end
  def content_adapter_inline_values
    def self.content_adapter_inline_values
      yield @sf_content_adapter_inline_values if block_given?
      @sf_content_adapter_inline_values
    end
    @sf_content_adapter_inline_values = Providers::InlineValuesAdapter.new({factory: self})
    yield @sf_content_adapter_inline_values if block_given?
    @sf_content_adapter_inline_values
  end

  ##
  # Adapter by Content
  # Will accepts ResultBean, Hash, ot single string value
  def adapter_for_content_profile_entry(content)
    content_type = (content.respond_to?(:to_hash) ? content['content_type'] : content)
    case content_type
      when "Commission", "Activity", "FileDownload"
        content_adapter_file_system
      when "Notification", "LicensedStates", "Operations"
        content_adapter_inline_values
      else
        content_adapter_file_system # default for now
    end
  end


end