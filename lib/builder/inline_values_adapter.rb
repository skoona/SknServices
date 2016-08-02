##
# lib/builder/inline_values_adapter.rb
#
# Parses ContentProfileEntries to extract inline values
#
#

module Builder
  class InlineValuesAdapter < ::Factory::ContentAdapterBase

    PREFIX_CONTENT = 'content'
    PREFIX_ACCESS = 'access'

    def initialize(params={})
      super(params)
    end

    def ready?
      true
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
      topic_type = cpe[:topic_type] || cpe["topic_type"]  # should always be an array
      content_type = cpe[:content_type] || cpe["content_type"]  # should always be an array
      topic_value = cpe[:topic_value] || cpe["topic_value"]  # should always be an array
      content_value = cpe[:content_value] || cpe["content_value"]  # should always be an array
      user_options = cpe[:user_options] || cpe["user_options"] || [] # many times this value is nil

      ##
      # This is another security check to see if user options include these topic ids
      ##
      access_type = !!(cpe.key?(:uri) or cpe.key?("uri"))
      paths = topic_value.map {|topic_id| "#{topic_type}/#{topic_id}/#{content_type}" if user_options.include?(topic_id) }.compact if access_type
      paths = topic_value.map {|topic_id| "#{topic_type}/#{topic_id}/#{content_type}" }.compact unless access_type

      paths.each do |path|
        content_values = content_value unless content_value.first.is_a?(Hash)
        content_values = content_value.map(&:values).flatten if content_value.first.is_a?(Hash)

        content_values.each do |cv|
              result << { source: path,
                          filename: cv.to_s,
                          created: DateTime.now.strftime("%m/%d/%Y"),
                          size: cpe["content_type_description"],
                          mime: "N/A"
              }
        end
      end
      Rails.logger.debug "#{self.class}##{__method__} Result: #{result}"
      
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

  end
end