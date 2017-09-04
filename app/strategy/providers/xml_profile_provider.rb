##
# File: <root>/app/strategy/providers/xml_profile_provider.rb
#
# ContentProfile from XML
#
# main Ref: https://docs.omniref.com/ruby/gems/activesupport/4.2.0/symbols/Hash/to_xml
#
# https://github.com/jimweirich/builder
# http://stackoverflow.com/questions/10541800/namespace-attributes-in-builder-gem
# https://github.com/rtomayko/tilt
#
# Storage thru Registry
# #######


module Providers
  class XMLProfileProvider < ProvidersBase

    PROVIDER_PREFIX = self.name

    def initialize(params={})
      super
      cpbf = SknSettings.access_profile.content_registry_filename.basename
      cpbx = SknSettings.access_profile.content_registry_filename.extension
      @content_registry_filename = Pathname.new("#{Rails.root}/config/#{cpbf}.#{cpbx}")
      @rootPath = 'contentRegistry'
      @optionsKeyword = SknSettings.access_profile.options_keyword
    end

    def self.provider_type
      PROVIDER_PREFIX
    end

    def provider_type
      PROVIDER_PREFIX
    end

    ##
    # Generators of Profile
    ##
    def content_profile_for_user(usr_profile, beaned=false)
      hsh = collect_content_profile_bean(usr_profile)
      beaned ? Utility::ContentProfileBean.new(hsh) : hsh
    end

    # Arrays of the following hash
    # parms = {
    #  "uri"=>"ContentType/TopicType/SomeKey",
    #  "content_type"=>"ContentType",
    #  "content_value"=>{:docType=>123, :drawerType=>4312},
    #  "topic_type"=>"TopicType",
    #  "topic_value"=>["0034", "0037", "0040"],
    #  "description"=>"XML Testing Data"
    # }
    # Create an XML version of a ContentProfileEntry from parms
    def create_content_profile_entry(parms, enabled=true)
      count = 0
      return 0 if parms.nil? or [parms].first.empty?

      document = Nokogiri::XML(IO.read(@content_registry_filename))

      Nokogiri::XML::Builder.with(document.at(@rootPath)) do |xml|

        [parms].flatten.compact.each do |parm|
          cpe = HashWithIndifferentAccess.new(parm)
          b,a,c = cpe[:uri].split('/')
          role_opts = [cpe[:topic_value]].flatten.join(',')
          ctv = encode_userdata_content(cpe[:content_value])

          xml.resource('secured' => 'true', 'content' => 'true' ) do
            xml.uri cpe[:uri]
            xml.description cpe[:description]
            xml.userdata ctv
            xml.permission('type' => 'READ') do
              xml.authorizedRoles do
                xml.authorizedRole(@optionsKeyword => role_opts) do
                  # ToDo: The TopicType/ContentType elements are largely fixed at development time and should not require admins to create more roles beyond the original set
                  xml.text "Services.#{a}.#{b}.Access"
                end
                xml.authorizedRole(@optionsKeyword => role_opts) do
                  # ToDo: Too Detailed, the third qualifier(c) will force repeated role creation by admins : Ignored for now
                  xml.text "Services.#{a}.#{b}.#{c}.Access"
                end
              end
            end
          end
          count += 1
        end # end loop

      end
      doc = Nokogiri::XML(document.to_xml, &:noblanks)  # restore pretty print
      if enabled and count > 0
        IO.write(@content_registry_filename, doc.to_xml)
      end
      Rails.logger.debug("#{self.class.name}.#{__method__}() Created: #{count}, Writing: #{ doc.to_xml}")
      count
    end

    # Arrays of the following hash
    # parms = {
    #  "uri"=>"ContentType/TopicType/SomeKey"
    # }
    # Deletes ALL nodes that match parms[:uri]
    def destroy_content_profile_entry(parms, enabled=true)
      count = 0
      return 0 if parms.nil? or [parms].first.empty?

      doc = Nokogiri::XML(IO.read(@content_registry_filename))

      [parms].flatten.compact.each do |parm|
        uri = parm['uri']
        doc.root.search("uri:contains('#{uri}')").each do |node|
          n = node.parent.unlink # parent.remove
          n.remove
          count += 1
        end
      end

      if enabled and count > 0
        IO.write(@content_registry_filename, doc.to_xml)
      end
      Rails.logger.debug("#{self.class.name}.#{__method__}() Deleted: #{count}, Writing: #{ doc.to_xml}")
      count
    end


  protected

    # encode userdata as Hash, Array,or String
    def encode_userdata_content(content_value)
      case content_value
        when Hash
          content_value.to_a.map() {|i| i.join(':') }.join('|')
        when Array
          content_value.map(&:to_s).join('|')
        else
          content_value
      end
    end

    # Not meant to be public, use send() to test
    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key)
    end

    ##
    # AccessProfile
    ##
    def collect_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      arobj = get_existing_profile(user_profile)
      return  arobj if arobj

      package = {
          success: true,
          entries: collect_context_profile_entry(user_profile) || [],
          pak: user_profile.person_authenticated_key,
          profile_type: user_profile.assigned_groups.first || "not assigned",
          profile_type_description: user_profile.assigned_groups.first || "not assigned",
          provider: "Secure::AccessRegistry",
          username: user_profile.username,
          assigned_group: user_profile.assigned_groups,
          user_options: user_profile.user_options,
          display_name: user_profile.display_name,
          email: user_profile.email
      }
      if package[:entries].empty?
        package = {
            success: false,
            message: "No access profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      unless package[:entries].empty?
        package[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
      end
      update_storage_object(user_profile.person_authenticated_key, package) if package[:success]

      Rails.logger.debug("#{self.class.name}.#{__method__}() returns: #{package.to_hash.keys}")
      package

    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      delete_storage_object(user_profile.person_authenticated_key) if user_profile.present?
      package = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end

    def collect_context_profile_entry(usrp)
      Secure::AccessRegistry.get_resource_content_entries(usrp.combined_access_roles, usrp.user_options )
    end

    ##
    # generate xml from a regular hash, with/out arrays
    def generate_xml_from_hash(hash, base_type, collection_key)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send(base_type) { process_simple_array(collection_key, hash, xml) }
      end

      builder.to_xml
    end

    ##
    # generate xml from a hash of hashes or array of hashes
    def generate_xml_from_nested_hashes(data, parent = false, opt = {})
      return if data.to_s.empty?
      return unless data.is_a?(Hash)

      unless parent
        # assume that if the hash has a single key that it should be the root
        root, data = (data.length == 1) ? data.shift : ["root", data]
        builder = Nokogiri::XML::Builder.new(opt) do |xml|
          xml.send(root) {
            generate_xml(data, xml)
          }
        end

        return builder.to_xml
      end

      data.each { |label, value|
        if value.is_a?(Hash)
          attrs = value.fetch('@attributes', {})
          # also passing 'text' as a key makes nokogiri do the same thing
          text = value.fetch('@text', '')
          parent.send(label, attrs, text) {
            value.delete('@attributes')
            value.delete('@text')
            generate_xml(value, parent)
          }

        elsif value.is_a?(Array)
          value.each { |el|
            # lets trick the above into firing so we do not need to rewrite the checks
            el = {label => el}
            generate_xml(el, parent)
          }

        else
          parent.send(label, value)
        end
      }
    end

    private

    # support for #generate_xml_from_hash
    def process_simple_array(label,array,xml)
      array.each do |hash|
        kids,attrs = hash.partition{ |k,v| v.is_a?(Array) }
        xml.send(label,Hash[attrs]) do
          kids.each{ |k,v| process_array(k,v,xml) }
        end
      end
    end

  end
end