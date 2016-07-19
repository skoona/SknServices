##
# lib/builder/file_system_adapter.rb
#
# Builds filelists
#
# Presumes this Directory Layout
# :./controlled/downloads/<topic_value>/content_values
# Ideal Layout would be: ./controlled/TopicType/TopicValue/ContentType/ 'ContentValue::Pattern'
# - where topic_value is in [:datafiles, :images, :pdf]
# - where content_value is a file.glob pattern
#

module Builder
  class FileSystemAdapter < ::Factory::ContentAdapterBase

    PREFIX_CONTENT = 'content'
    PREFIX_ACCESS = 'access'

    def initialize(params={})
      super(params)
      @topic_values = {
          datafiles: './controlled/downloads/datafiles/',
          images: './controlled/downloads/images/',
          pdf: './controlled/downloads/pdf/'
      }
      @file_system = Pathname('./controlled/projects')
    end

    def ready?
      @file_system.exist?
    end


    # Takes a ContentProfileEntry CPE
    # Parameters: {"id"=>"content",
    #              "username"=>"aptester",
    #              "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
    #              "content_type"=>"Commission",
    #              "content_value"=>["68613"],
    #              "topic_type"=>"Branch",
    #              "topic_value"=>["0038"],
    #              "description"=>"Determine which branch documents can be seen",
    #              "topic_type_description"=>"Branch Actions for a specific branch",
    #              "content_type_description"=>"Monthly Commission Reports and Files"
    # }
    # Parameters: {"id"=>"access",
    #              "username"=>"aptester",
    #              "user_options"=>["BranchPrimary", "0034", "0037", "0040"],
    #              "uri"=>"Commission/Branch/PDF",
    #              "resource_options"=>{
    #                  "uri"=>"Commission/Branch/PDF",
    #                  "role"=>"Test.Branch.Commission.Statement.PDF.Access",
    #                  "role_opts"=>["0034", "0037", "0040"]
    #              },
    #              "content_type"=>"Commission",
    #              "content_value"=>{"0"=>{"doctype"=>"954"}},
    #              "topic_type"=>"Branch",
    #              "topic_value"=>["0034", "0037", "0040"],
    #              "description"=>"Branch Commission Statements",
    #              "topic_type_description"=>"Branch Commission Statements",
    #              "content_type_description"=>"Branch Commission Statements"
    # }
    # Returns and array of {source: "", filename: "", created: "", size: ""}
    def available_content_list(cpe)
      result = []
      base_path = cpe[:base_path] || @file_system.to_path
      topic_type = cpe[:topic_type] || cpe["topic_type"]  # should always be an array
      content_type = cpe[:content_type] || cpe["content_type"]  # should always be an array
      topic_value = cpe[:topic_value] || cpe["topic_value"]  # should always be an array
      paths = topic_value.map {|topic_id| Pathname.new("#{base_path}/#{topic_type}/#{topic_id}/#{content_type}") }
      paths.each do |path|
        Dir.glob(File.join(path.to_path, "**") ).collect {|f| Pathname.new(f) }.each do |pn|
          result << { source: cpe["content_type_description"], # topic.to_s,
                      filename: pn.basename.to_s,
                      created: pn.ctime.strftime("%Y/%m/%d"),
                      size: human_filesize(pn.size),
                      mime: content_mime_type(pn.extname)
                    }
        end
      end
      Rails.logger.debug "#{self.class}##{__method__} result: #{result}"
      
      result
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end


    # Returns an Array|Hash of Values
    def retrieve_content_values(cpe={}) # ContentProfileEntry Hash
      result = cpe[:content_value] || cpe["content_value"] || []

      Rails.logger.debug "#{self.class}##{__method__} result: #{result}"
      result
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      []
    end

    # Composes a new path from the CPE
    def create_new_content_entry_path(cpe={}, opts={}) # ContentProfileEntry Hash, { noop: true, mode: 0700, verbose: true }
      base_path = cpe[:base_path] || @file_system.to_path
      topic_type = cpe[:topic_type] || cpe["topic_type"]  # should always be an array
      content_type = cpe[:content_type] || cpe["content_type"]  # should always be an array
      topic_value = cpe[:topic_value] || cpe["topic_value"]  # should always be an array
      paths = topic_value.map {|topic_id| Pathname.new("#{base_path}/#{topic_type}/#{topic_id}/#{content_type}") }
      paths.each do |path|
        FileUtils.mkpath(path.to_path, opts) unless path.exist?
      end

    Rails.logger.debug "#{self.class}##{__method__} result: #{paths.map(&:to_s)}"
      true
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      false
    end

    protected

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