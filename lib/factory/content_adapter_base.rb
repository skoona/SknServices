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
      return 'text/plain' if extname.downcase.include?('log')
      Mime::Type.lookup_by_extension(extname).to_str rescue 'application/octet-stream'
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

    protected

    def get_page_user(uname, context=nil)
      page_user = Secure::UserProfile.page_user(uname, context)
    end

    def sanitize(filename)
      value = filename
      # Remove any leading navigation
      value = value[2..-1] if value.start_with?('..')
      value = value[2..-1] if value.start_with?('./')
      value = value[1..-1] if value.start_with?('/')
      # Remove any character that aren't 0-9, A-Z, or a-z
      value = value.gsub(/[^0-9A-Z]/i, '_')
      value
    end

    # Rails should have a 'number_to_human_size()' in some version ???
    def human_filesize(value)
      {
          'B'  => 1024,
          'KB' => 1024 * 1024,
          'MB' => 1024 * 1024 * 1024,
          'GB' => 1024 * 1024 * 1024 * 1024,
          'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.each_pair { |e, s| return "#{(value.to_f / (s / 1024)).round(1)} #{e}" if value < s }
    end

  end
end
