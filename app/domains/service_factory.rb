## app/domains/service_factory.rb
#
# Replace factory helpers with Factory Object for DomainsBase
# - Domain services live for one request cycle and are expensive to create, this object memorizes them
# - This factory should be passed around like "factory"
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory
class ServiceFactory < ::Factory::FactoriesBase


  ##
  # Application Services used in Controller methods
  ##

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

  ##
  # Content Providers
  ##

  def xml_profile_provider
    @sf_xml_profile_builder ||= Builder::XMLProfileProvider.new({factory: self})
    yield @sf_xml_profile_builder if block_given?
    @sf_xml_profile_builder
  end
  def db_profile_provider
    @sf_db_profile_builder ||= Builder::DBProfileProvider.new({factory: self})
    yield @sf_db_profile_builder if block_given?
    @sf_db_profile_builder
  end

  ##
  # Content Adapters
  ##

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
      when "Commission", "Activity", "FileDownload"
        content_adapter_file_system
      when "Notification", "LicensedStates", "Operations"
        content_adapter_inline_values
      else
        content_adapter_file_system # default for now
    end
  end


end