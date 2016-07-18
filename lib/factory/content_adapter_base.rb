##
# File: <root>/lib/factory/content_adapter_base.rb
#
# Retrieves content for target system

module Factory
  class ContentAdapterBase < DomainsBase

    def ready?
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end
    # Ruby only Alternate: MIME::Types.type_for(full_filename), using mime.gem
    def content_mime_type(extension)
      extname = extension.gsub(/^\./,'')
      Mime::Type.lookup_by_extension(extname).to_str || nil
    end
    def available_content_list(params={})  # ContentProfileEntry Hash
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end
    def retrieve_content_object(params={}) # Hash entry result from available_content_list method
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end
    def retrieve_content_values(params={}) # ContentProfileEntry Hash
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end

    def create_new_content_entry_path(params={}) # ContentProfileEntry Hash
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end
    def add_new_content_entry_object(params={}, object_to_store=nil) # ContentProfileEntry Hash and object
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end
    def remove_content_entry_object(params={}, object_to_store=nil) # ContentProfileEntry Hash and object
      raise NotImplementedError, "#{self.name}##{__method__} Not Implemented!"
    end

  end
end
