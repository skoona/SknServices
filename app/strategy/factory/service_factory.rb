## app/strategy/service_factory.rb
#
# Replace factory helpers with Factory Object from DomainsBase
# - Domain strategy.services live for one request cycle and are expensive to create, this object memoitizes them
# - This factory should be passed around like "factory" or "service"
# - Should make testing easier
#

# self is factory
# factory is the thing that initialized us: i.e. controller is really factory
module Factory

  class ServiceFactory < ::Factory::FactoriesBase


    ##
    # Application Services used in Controller methods
    ##

    def access_service
      @sf_access_service ||= Services::AccessService.new({factory: self})       # First call will execute this set of code
      yield @sf_access_service if block_given?
      @sf_access_service
    end

    def content_service
      @sf_content_service ||= Services::ContentService.new({factory: self})
      yield @sf_content_service if block_given?
      @sf_content_service
    end

    ##
    # Content Providers
    ##

    def xml_profile_provider
      @sf_xml_profile_builder ||= Providers::XMLProfileProvider.new({factory: self})
      yield @sf_xml_profile_builder if block_given?
      @sf_xml_profile_builder
    end

    def db_profile_provider
      @sf_db_profile_builder ||= Providers::DBProfileProvider.new({factory: self})
      yield @sf_db_profile_builder if block_given?
      @sf_db_profile_builder
    end

    ##
    # Content Adapters
    ##

    def content_adapter_file_system
      @sf_content_adapter_file_system ||= Processors::FileSystemAdapter.new({factory: self})
      yield @sf_content_adapter_file_system if block_given?
      @sf_content_adapter_file_system
    end

    def content_adapter_inline_values
      @sf_content_adapter_inline_values ||= Processors::InlineValuesAdapter.new({factory: self})
      yield @sf_content_adapter_inline_values if block_given?
      @sf_content_adapter_inline_values
    end

    ##
    # Adapter by Content
    # Will accepts ResultBean, Hash, or single string value
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
end