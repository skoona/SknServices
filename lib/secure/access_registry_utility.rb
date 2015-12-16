#
# lib/Secure/access_registry_utility.rb
#
# Converts AccessRegistry XML Permissions file to YAMLable hash format.
# -  Inputs: AccessRegistry xmlFile
# - Outputs: a hash with the contents of the xml file
#
# Author: James Scott, Jr. <jscott@skoona.net>
# Feb 27, 2013
#

# <accessRegistry>
  # <resource secured="false">
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

    # Initialize object and load the xmlFile
    def initialize (xml_filename)
      relative_xmlfile = "#{Rails.root}/config/#{xml_filename}.xml"
      raise AccessRegistryError, "No such file or directory - #{relative_xmlfile}" unless File.exist? relative_xmlfile

      @xml_doc =  Nokogiri::XML(File.open(relative_xmlfile, "r")).xpath("/accessRegistry/resource")
      Rails.logger.debug "Processing xml file => [#{relative_xmlfile}]"
    end

    # Convert xml to Hash format
    def from_xml (xml_node_set=nil)
      xml_node_set = @xml_doc unless xml_node_set.present?
      resource_hash = Hash.new
      resource_uri = ""
      key = ""
      xml_node_set.each do |resource|
        next unless resource.xpath("uri").present?

        # populate the head of resource hash
        resource_uri = resource.xpath("uri").text
        resource_hash[resource_uri] = {}

        resource_hash[resource_uri]["secured"] = false

        resource_hash[resource_uri]["secured"] = resource["secured"].include? "true" if resource["secured"].present?
        resource_hash[resource_uri]["description"] = resource.xpath("description").text.squish if resource.xpath("description").present?

        # populate the individual permissions
        resource.xpath("permission").each do |permission|
          # ignore \n and other blank entries
          next unless permission.has_attribute? "type"

          key = permission["type"]
          resource_hash[resource_uri][key] = {}

          permission.xpath("authorizedRoles/authorizedRole").each do |authorized|
            next unless authorized.text.present?

            name = authorized.text
            role = []
            role = authorized["options"].squish.split(",").collect {|item| item.squish } if authorized.has_attribute? "options"
            resource_hash[resource_uri][key].store(name,role)
          end # end authorized role
        end # end permission name

      end # end resource sets
      #File.open("./ar_permissions.yml", "w") do |file|
      #      YAML::dump(resource_hash, file)
      #end

      resource_hash
    end  # end from_xml()

  end # end class
end # end module
