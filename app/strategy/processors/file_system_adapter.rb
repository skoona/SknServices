##
# lib/providers/file_system_adapter.rb
#
# Builds filelists
#
# Presumes this Directory Layout
# :./controlled/downloads/<topic_value>/content_values
# Ideal Layout would be: ./controlled/TopicType/TopicValue/ContentType/ 'ContentValue::Pattern'
# - where topic_value is in [:datafiles, :images, :pdf]
# - where content_value is a file.glob pattern
#
#
# CONTROLLER SEND FILE METHOD
#
# def download_pdf(name)
#   send_file("#{Rails.root}/files/clients/#{name}.pdf",
#             filename: "#{name}.pdf",
#             type: "application/pdf")
# end

module Processors
  class FileSystemAdapter < ProcessorBase

    PREFIX_CONTENT = 'content'
    PREFIX_ACCESS  = 'access'
    PREFIX_CATALOG = 'Catalog'

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
      paths = []
      catalog = {}

      base_path = cpe[:base_path] || @file_system.to_path
      topic_type = cpe[:topic_type] || cpe["topic_type"]  # should always be an array
      content_type = cpe[:content_type] || cpe["content_type"]  # should always be an array
      topic_value = cpe[:topic_value] || cpe["topic_value"]  # should always be an array
      content_value = cpe[:content_value] || cpe["content_value"]  # should always be an array
      user_options = cpe["user_options"] || [] # many times this value is nil
      page_user = get_page_user(cpe["username"] || cpe[:username])

      ##
      # This is another security check to see if user options include these topic ids for XML Entries only
      ##
      access_type = (cpe.key?(:resource_options) or cpe.key?("resource_options"))
      paths = topic_value.map {|topic_id| Pathname.new("#{base_path}/#{topic_type}/#{topic_id}/#{content_type}") if user_options.include?(topic_id) }.compact if access_type
      paths = topic_value.map {|topic_id| Pathname.new("#{base_path}/#{topic_type}/#{topic_id}/#{content_type}") }.compact unless access_type

      paths.each_with_index do |path,pidx|
        content_values = content_value unless content_value.first.is_a?(Hash)
        content_values = content_value.map(&:values).flatten if content_value.first.is_a?(Hash)

        content_values.each_with_index do |cv,cidx|
            Dir.glob(File.join(path.to_path, cv.to_s) ).collect {|f| Pathname.new(f) }.each_with_index do |pn,idx|
              next unless pn.exist?
              result << { source: path.to_path.split("/")[3..-1].join("/"),
                          filename: pn.basename.to_s,
                          created: pn.ctime.strftime("%Y/%m/%d"),
                          size: human_filesize(pn.size),
                          mime: content_mime_type(pn.extname),
                          username: cpe["username"] || cpe[:username],
                          id: "#{pidx}:#{cidx}:#{idx}",
                          content_type: content_type
                        }
              catalog.store("#{pidx}:#{cidx}:#{idx}", { source: pn, filename: pn.basename.to_s, mime: content_mime_type(pn.extname)} )
            end
        end
      end
      factory.update_storage_object("#{PREFIX_CATALOG}-#{page_user.person_authenticated_key}", catalog)
      Rails.logger.debug "#{self.class}##{__method__} Catalog: #{catalog}, Result: #{result}"
      
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

    # {"id"=>"0:0:1", "username"=>"developer", content_type="Commission" "controller"=>"profiles", "action"=>"api_get_content_object"}
    def retrieve_content_object(params, user_p=nil) # Hash entry result from available_content_list method
      page_user = user_p || (get_page_user(params["username"] || params[:username]))

      catalog = factory.get_storage_object("#{PREFIX_CATALOG}-#{page_user.person_authenticated_key}")
      result = {
          success: true,
          package: catalog.try(:[], params[:id]) || {}              # { source:, filename: , mime: }  key should be :id but prior method flipped value to :profile
      }
      Rails.logger.debug "#{self.class}##{__method__}() Catalog: #{catalog}, Result: #{result}"

      result

    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}(catalog: #{catalog}) Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      {
          success: false,
          package: {}
      }
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

  end
end