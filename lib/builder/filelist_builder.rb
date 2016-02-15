##
# lib/builder/filelist_builder.rb
#
# Builds filelists
#
# Presumes this Directory Layout
# :./controlled/downloads/<topic_value>/content_values
# - where topic_value is in [:datafiles, :images, :pdf]
# - where content_value is a file.glob pattern
#

module Builder
  class FilelistBuilder < ::Factory::DomainsBase

    PREFIX_CONTENT = 'content'
    PREFIX_ACCESS = 'access'

    def initialize(params={})
      super(params)
      @topic_values = {
          datafiles: './controlled/downloads/datafiles/',
          images: './controlled/downloads/images/',
          pdf: './controlled/downloads/pdf/'
      }
    end

    # Returns and array of {source: "", filename: "", created: "", size: ""}
    def request_content_filelist(params)
      topic = params[:topic]
      content = params[:content]
        return [] unless topic and content

      result = []
      get_content(topic, content).each do |pn|
        result << {source: topic.to_s, filename: pn.basename.to_s, created: pn.ctime.strftime("%Y/%m/%d"), size: human_filesize(pn.size) }
      end

      result
    end

    protected

    # Returns an Array of Pathnames
    def get_content(topic_value_sym, content_values)
      path = File.join(@topic_values[topic_value_sym],content_values)
      Dir.glob(path).collect {|f| Pathname.new(f) }
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
      }.each_pair { |e, s| return "#{(value.to_f / (s / 1024)).round(2)} #{e}" if value < s }
    end

  end
end