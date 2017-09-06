#
# lib/Secure/access_registry_utility.rb
#
# Converts Secure::AccessRegistry XML Permissions file to YAMLable hash format.
# -  Inputs: AccessRegistry xmlFile
# - Outputs: a hash with the contents of the xml file
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Feb 27, 2013
#

# <accessRegistry>
  # <resource secured="false" content="true">
    # <description>Ajax4JSF Library Calls</description>
    # <uri>/a4j_3_1_4</uri>
    # <permission type="CREATE">
      # <authorizedRoles>
        # <authorizedRole options="anyValue">security-role-name</authorizedRole>
        # <authorizedRole>or-security-group-name</authorizedRole>
      # </authorizedRoles>
    # </permission>
    # <permission type="READ">
      # <authorizedRoles>
        # <authorizedRole>All Authorized Users</authorizedRole>
      # </authorizedRoles>
    # </permission>
    # ... permission [ CREATE, READ, UPDATE, DELETE ]
  # </resource> 
  # ... resources
# </accessRegistry>

##
#  Output Hash
#  access_registry = {
#    "uri" = {
#      "secured" => true,
#      "content" => true,
#      "topic_value_regex" => "^\d{4}",
#      "userdata" => 'String,Array,Hash',
#      "description" => "some description",
#      "CREATE" => {
#        "role name" => ["status","status",...],        
#        "role n" => []
#      },
#      "READ" => {
#        "role name" => ["status","status",...],        
#        "role n" => []
#      },
#      "UPDATE" => {
#        "role name" => ["status","status",...],        
#        "role n" => []
#      },
#      "DELETE" => {
#        "role name" => ["status","status",...],        
#        "role n" => []
#      }
#    }, ...
#  }
#

module Secure
  class AccessRegistryUtility
    @@ar_options_keyword = SknSettings.access_profile.options_keyword

    # Initialize object and load the xmlFile
    def initialize (xml_filename, rootPath='accessRegistry')
      relative_xpath = "//xmlns:#{rootPath}/xmlns:resource"
      relative_xmlfile = "#{Rails.root}/config/#{xml_filename}.xml"
      raise AccessRegistryError, "No such file or directory - #{relative_xmlfile}" unless File.exist? relative_xmlfile

      @xml_doc =  Nokogiri::XML(File.open(relative_xmlfile, "r")) do |config|
        config.strict.noblanks
      end.xpath(relative_xpath)
      # TODO: As an alternate to using the Namespaces (xmlns:node), you remove all namespaces with:
      # TODO: - doc.remove_namespaces!
      Rails.logger.debug "Processing xml file => [#{relative_xmlfile}]"
      true
    end

    def self.call(xml_filename, rootPath='accessRegistry')
      xml_hash = new(xml_filename, rootPath).call()
      # pp self.class, __method__, xml_hash
      xml_hash
    end

    # Convert xml to Hash format
    #
    #File.open("./ar_permissions.yml", "w") do |file|
    #      YAML::dump(resource_hash, file)
    #end
    def from_xml (xml_node_set=nil)
      xml_node_set = @xml_doc unless xml_node_set.present?
      resource_hash = HashWithIndifferentAccess.new
      resource_uri = ""
      key = ""

      xml_node_set.each do |resource|
        next unless resource.xpath("xmlns:uri").present? or !resource.name.eql?("text")

        # populate the head of resource hash
        resource_uri = resource.xpath("xmlns:uri").text.squish
        resource_hash[resource_uri] = {}
        resource_hash[resource_uri]["secured"] = false
        resource_hash[resource_uri]["secured"] = resource["secured"] = true if resource["secured"].present? and resource["secured"].eql?("true")

        resource_hash[resource_uri]["content"] = false
        resource_hash[resource_uri]["content"] = resource["content"] = true if resource["content"].present? and resource["content"].eql?("true")

        resource_hash[resource_uri]["topic_value_regex"] = resource["topicValueRegex"] if resource["topicValueRegex"].present?

        # siblings
        resource.children.each  do |sibl|
          next if ["uri", "text"].include?(sibl.name)
          keystr = sibl.name

          if keystr.eql?("permission")
            # populate the individual permissions
            next unless sibl.has_attribute? "type"

            key = sibl["type"]
            resource_hash[resource_uri][key] = {}

            sibl.xpath("xmlns:authorizedRoles/xmlns:authorizedRole").each do |authorized|
              next unless authorized.text.present?

              name = authorized.text
              role = []
              role = authorized[@@ar_options_keyword].squish.split(",").collect {|item| item.squish } if authorized.has_attribute?(@@ar_options_keyword)

              next if resource_hash[resource_uri]["content"] and (!authorized.key?(@@ar_options_keyword) || authorized[@@ar_options_keyword].nil? ) # options are required for content xmls

              resource_hash[resource_uri][key].store(name,role)
            end # end authorized role
          else # of permission
            resource_hash[resource_uri][keystr] = decode_userdata_content(keystr, sibl.content.squish)
          end

        end # of sibling

        #
        # Filter out Content entries without options
        empty_index = 0
        indexes = 0
        Secure::AccessRegistry::CRUD_MODES.each_with_index do |crud, index|
          empty_index += 1 if !resource_hash[resource_uri].key?(crud) || resource_hash[resource_uri][crud].empty?
          indexes += 1
        end
        if resource_hash[resource_uri]["content"] and (empty_index == indexes)
          Rails.logger.debug( " --:Rejecting Invalid Content Entry: #{resource_uri}: #{ resource_hash.delete(resource_uri) }" )
        end

      end # of node_set

      resource_hash
    end  # end from_xml()
    alias_method :call, :from_xml

    # UserData Required format/syntax is:
    #   value|value|...
    #   key:value|key:value|...
    #   Reserved chars: |:     - vertical-bar and semi-colon
    def decode_userdata_content(name, value)
      return value unless name.eql?("userdata")
      return value.gsub('"','') unless value.match(/[\||:]/)

      a_result = []
      h_result = HashWithIndifferentAccess.new

      value = value.gsub('"','')

      a_result = value.split('|') if value.match(/\|/)
      a_result = [value] if a_result.empty?

      if a_result.first.match(/:/)
        a_result.each do |outer|
          item = outer.split(':')
          h_result.store(item[0].strip, item[1].strip)
        end
      end

      h_result.empty? ? a_result : h_result
    end

  end # end class
end # end module
