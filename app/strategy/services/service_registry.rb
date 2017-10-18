## app/strategy/service_registry.rb
#
# Replace registry helpers with Registry Object from DomainsBase
# - Domain strategy.services live for one request cycle and are expensive to create, this object memoitizes them
# - This registry is available in the namespace of all services, domains, and multi-method processors
# - Should make testing easier, see: ServiceRegistryMockController in spec/support dir.
#

# self is registry
# registry is the thing that initialized us: i.e. controller is really registry
module Services

  class ServiceRegistry < ::Registry::RegistryBase


    ##
    # Application Services used in Controller methods
    ##

    def access_service
      @sr_access_service ||= AccessService.new({registry: self})       # First call will execute this set of code
    end

    def content_service
      @sr_content_service ||= ContentService.new({registry: self})
    end

    def password_reset_use_case
      @sr_password_reset_use_case ||= ::UseCases::PasswordResetUseCase.new({registry: self})
    end

    ##
    # Content Providers
    ##

    def xml_profile_provider
      @sr_xml_profile_builder ||= Providers::XMLProfileProvider.new({registry: self})
    end

    def db_profile_provider
      @sr_db_profile_builder ||= Providers::DBProfileProvider.new({registry: self})
    end

    ##
    # Content Adapters
    ##

    def content_adapter_file_system
      @sr_content_adapter_file_system ||= Processors::FileSystemProcessor.new({registry: self})
    end

    def content_adapter_inline_values
      @sr_content_adapter_inline_values ||= Processors::InlineValuesProcessor.new({registry: self})
    end

    ##
    # Adapter by Content
    # Will accepts ResultBean, Hash, or single string value
    def adapter_for_content_profile_entry(content)
      content_type = (content.respond_to?(:to_hash) ? (content[:content_type] || content['content_type']) : content)
      case content_type
        when "Commission", "Activity", "FileDownload", 'Experience', 'FileDownload'
          content_adapter_file_system
        when "Notification", "LicensedStates"
          content_adapter_inline_values
        else
          content_adapter_file_system # default for now
      end
    end


  end
end