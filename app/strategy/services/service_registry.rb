## app/strategy/service_registry.rb
#
# Replace registry helpers with Registry Object from DomainsBase
# - Domain strategy.services live for one request cycle and are expensive to create, this object memoitizes them
# - This registry is available in the namespace of all services, domains, and multi-method processors
# - Should make testing easier
#

# self is registry
# registry is the thing that initialized us: i.e. controller is really registry
module Services

  class ServiceRegistry < ::Registry::RegistryBase


    ##
    # Application Services used in Controller methods
    ##

    def access_service
      @sf_access_service ||= AccessService.new({registry: self})       # First call will execute this set of code
      yield @sf_access_service if block_given?
      @sf_access_service
    end

    def content_service
      @sf_content_service ||= ContentService.new({registry: self})
      yield @sf_content_service if block_given?
      @sf_content_service
    end

    ##
    # Content Providers
    ##

    def xml_profile_provider
      @sf_xml_profile_builder ||= Providers::XMLProfileProvider.new({registry: self})
      yield @sf_xml_profile_builder if block_given?
      @sf_xml_profile_builder
    end

    def db_profile_provider
      @sf_db_profile_builder ||= Providers::DBProfileProvider.new({registry: self})
      yield @sf_db_profile_builder if block_given?
      @sf_db_profile_builder
    end

    ##
    # Content Adapters
    ##

    def content_adapter_file_system
      @sf_content_adapter_file_system ||= Processors::FileSystemAdapter.new({registry: self})
      yield @sf_content_adapter_file_system if block_given?
      @sf_content_adapter_file_system
    end

    def content_adapter_inline_values
      @sf_content_adapter_inline_values ||= Processors::InlineValuesAdapter.new({registry: self})
      yield @sf_content_adapter_inline_values if block_given?
      @sf_content_adapter_inline_values
    end

    ##
    # Adapter by Content
    # Will accepts ResultBean, Hash, or single string value
    def adapter_for_content_profile_entry(content)
      content_type = (content.respond_to?(:to_hash) ? (content[:content_type] || content['content_type']) : content)
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