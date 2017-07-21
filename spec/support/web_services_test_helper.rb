##
#
# Mocks the WebServices Requests using xml response in the factories directory
#
# Savon.observers << WebServicesTestHelper::Observer.new

module WebServicesTestHelper

  class Observer
    def initialize
      super
      @test_data = []
      Dir.glob("#{Rails.root}/spec/factories/web_services/*.xml").each do |f|
        item = /(\w*)\.?(.*)/.match(File.basename(f)[0..-5])
        Fixture.add_fixture(item[0])  # name.req_key
        @test_data.push item[0]
      end
      true
    end

    #
    # rspec_code = the desired return code
    # rspec_req = the file attribute needed for test data
    def notify(operation_name, builder, globals, locals)
      rspec_code = locals[:message].delete(:rspec_code)
      rspec_req = locals[:message].delete(:rspec_req)

      code    = rspec_code || 200
      headers = {}
      body    = ""
      req_key = "#{operation_name.to_s}_response"
      req_key = "#{operation_name.to_s}_response.#{rspec_req}" if rspec_req.present?
      req_key = "soap_fault_response" if code == 500

      Rails.logger.debug "#{self.class.name}.#{__method__}() Operation: #{operation_name} USING_MOCKED_DATA: #{@test_data.include?(req_key)}, Fixture: #{req_key}"

      if  @test_data.include?(req_key)
          HTTPI::Response.new(code, headers, Fixture.get_fixture(req_key))
      else
          nil
      end
    end

  end


  class Fixture

    class << self  # MAKE THE METHODS ADDED BE CLASS METHODS

      def add_fixture(fixture)
        fixtures(fixture)
        true
      end

      def get_fixture(fixture)
        fixtures(fixture)
      end

      def response_hash(fixture)
        @response_hash ||= {}
        @response_hash[fixture] ||= nori.parse(fixtures(fixture))[:envelope][:body]
      end

      private

      def nori
        Nori.new(strip_namespaces: false, convert_tags_to: lambda { |tag| tag.snakecase.to_sym })
      end

      def fixtures(fixture)
        @fixtures ||= {}
        @fixtures[fixture] ||= read_file fixture
      end

      def read_file(fixture)
        path = Rails.root.join("spec/factories/web_services/", "#{fixture}.xml").expand_path
        raise ArgumentError, "Unable to load: #{path}" unless path.exist?

        path.read
      end

    end
  end

end
