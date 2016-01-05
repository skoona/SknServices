#
# lib/Secure/access_registry_utility.rb
#
# Converts Secure::AccessRegistry XML Permissions file to YAMLable hash format.
# -  Inputs: AccessRegistry xmlFile
# - Outputs: a hash with the contents of the xml file
#
# Author: James Scott, Jr. <jscott@skoona.net>
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
    @@ar_options_keyword = Settings.access_profile.options_keyword

    # Initialize object and load the xmlFile
    def initialize (xml_filename)
      relative_xmlfile = "#{Rails.root}/config/#{xml_filename}.xml"
      raise AccessRegistryError, "No such file or directory - #{relative_xmlfile}" unless File.exist? relative_xmlfile

      @xml_doc =  Nokogiri::XML(File.open(relative_xmlfile, "r")).xpath("/accessRegistry/resource")
      Rails.logger.debug "Processing xml file => [#{relative_xmlfile}]"
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
        next unless resource.xpath("uri").present? or !resource.name.eql?("text")

        # populate the head of resource hash
        resource_uri = resource.xpath("uri").text.squish
        resource_hash[resource_uri] = {}
        resource_hash[resource_uri]["secured"] = false
        resource_hash[resource_uri]["secured"] = resource["secured"] = true if resource["secured"].present? and resource["secured"].eql?("true")

        resource_hash[resource_uri]["content"] = false
        resource_hash[resource_uri]["content"] = resource["content"] = true if resource["content"].present? and resource["content"].eql?("true")

        # siblings
        resource.children.each  do |sibl|
          next if ["uri", "text"].include?(sibl.name)
          keystr = sibl.name

          if keystr.eql?("permission")
            # populate the individual permissions
            next unless sibl.has_attribute? "type"

            key = sibl["type"]
            resource_hash[resource_uri][key] = {}

            sibl.xpath("authorizedRoles/authorizedRole").each do |authorized|
              next unless authorized.text.present?

              name = authorized.text
              role = []
              role = authorized[@@ar_options_keyword].squish.split(",").collect {|item| item.squish } if authorized.has_attribute?(@@ar_options_keyword)
              resource_hash[resource_uri][key].store(name,role)
            end # end authorized role
          else # of permission
            resource_hash[resource_uri][keystr] = process_resource_content(keystr, sibl.content.squish)
          end

        end # of sibling
      end # of node_set

      resource_hash
    end  # end from_xml()

    # UserData Required format/syntax is:
    #   value|value|...
    #   key:value|key:value|...
    #   Reserved chars: |:     - vertical-bar and semi-colon
    def process_resource_content(name, value)
      return value unless name.eql?("userdata")
      return value unless value.match(/[\||:]/)

      a_result = []
      h_result = HashWithIndifferentAccess.new

      value = value.gsub('"','')

      a_result = value.split('|') if value.match(/\|/)
      a_result = [value] if a_result.empty?

      if value.match(/:/)
        a_result.each do |outer|
          item = outer.split(':')
          h_result.store(item[0].strip, item[1].strip)
        end
      end

      h_result.empty? ? a_result : h_result
    end

  end # end class
end # end module
