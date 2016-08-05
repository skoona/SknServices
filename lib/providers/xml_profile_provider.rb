##
# lib/providers/xml_profile_provider.rb
#
# ContentProfile from XML
#
# main Ref: https://docs.omniref.com/ruby/gems/activesupport/4.2.0/symbols/Hash/to_xml
#
# https://github.com/jimweirich/builder
# http://stackoverflow.com/questions/10541800/namespace-attributes-in-builder-gem
# https://github.com/rtomayko/tilt
#
# Storage thru Factory
# #######
#
# ## Refe: http://codereview.stackexchange.com/questions/51569/building-xml-by-enumerating-through-array-hashes
#
#
# data = [
#     { 'name' => 'category1',
#       'subCategory' => [
#           { 'name' => 'subCategory1',
#             'product' => [
#                 { 'name' => 'productName1',
#                   'desc' => 'desc1' },
#                 { 'name' => 'productName2',
#                   'desc' => 'desc2' } ]
#           } ]
#     },
#     { 'name' => 'category2',
#       'subCategory' => [
#           { 'name' => 'subCategory2.1',
#             'product' => [
#                 { 'name' => 'productName2.1.1',
#                   'desc' => 'desc1' },
#                 { 'name' => 'productName2.1.2',
#                   'desc' => 'desc2' } ]
#           } ]
#     },
# ]
#
# require 'nokogiri'
#
# def process_array(label,array,xml)
#   array.each do |hash|
#     xml.send(label) do                 # Create an element named for the label
#       hash.each do |key,value|
#         if value.is_a?(Array)
#           process_array(key,value,xml) # Recurse
#         else
#           xml.send(key,value)          # Create <key>value</key> (using variables)
#         end
#       end
#     end
#   end
# end
#
# builder = Nokogiri::XML::Builder.new do |xml|
#   xml.root do                           # Wrap everything in one element.
#     process_array('category',data,xml)  # Start the recursion with a custom name.
#   end
# end
#
# puts builder.to_xml
# ######
# <?xml version="1.0"?>
#     <root>
#       <category>
#         <name>category1</name>
#         <subCategory>
#           <name>subCategory1</name>
#           <product>
#             <name>productName1</name>
#             <desc>desc1</desc>
#           </product>
#           <product>
#             <name>productName2</name>
#             <desc>desc2</desc>
#           </product>
#         </subCategory>
#       </category>
#       <category>
#       <name>category2</name>
#       <subCategory>
#         <name>subCategory2.1</name>
#         <product>
#           <name>productName2.1.1</name>
#           <desc>desc1</desc>
#         </product>
#         <product>
#           <name>productName2.1.2</name>
#           <desc>desc2</desc>
#         </product>
#       </subCategory>
#     </category>
# </root>
# ######
#
#  OR
#
# require 'nokogiri'
#
# def process_array(label,array,xml)
#   array.each do |hash|
#     kids,attrs = hash.partition{ |k,v| v.is_a?(Array) }
#     xml.send(label,Hash[attrs]) do
#       kids.each{ |k,v| process_array(k,v,xml) }
#     end
#   end
# end
#
# builder = Nokogiri::XML::Builder.new do |xml|
#   xml.root{ process_array('category',data,xml) }
# end
#
# puts builder.to_xml
# ######
# <?xml version="1.0"?>
# <root>
#   <category name="category1">
#     <subCategory name="subCategory1">
#       <product name="productName1" desc="desc1"/>
#       <product name="productName2" desc="desc2"/>
#     </subCategory>
#   </category>
#   <category name="category2">
#     <subCategory name="subCategory2.1">
#       <product name="productName2.1.1" desc="desc1"/>
#       <product name="productName2.1.2" desc="desc2"/>
#       </subCategory>
#   </category>
# </root>
# ######


module Providers
  class XMLProfileProvider < ::Factory::ProvidersBase

    PROVIDER_PREFIX = self.name

    def initialize(params={})
      super(params)
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

    # Not ment to be public, it is for testing reason
    def get_existing_profile(usr_prf)
      raise Utility::Errors::NotFound, "Invalid UserProfile!" unless usr_prf.present?
      get_prebuilt_profile(usr_prf.person_authenticated_key)
    end

    protected
    ##
    # AccessProfile
    ##
    def collect_content_profile_bean(user_profile)
      raise Utility::Errors::NotFound, "Invalid User Object!" unless user_profile.present?
      arobj = get_existing_profile(user_profile)
      return  arobj if arobj

      results = {
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
      if results[:entries].empty?
        results = {
            success: false,
            message: "No access profile data available for #{user_profile.display_name}",
            username: user_profile.username,
            entries:[]
        }
      end
      unless results[:entries].empty?
        results[:entries].each {|au| au.merge!(username: user_profile.username, user_options: user_profile.user_options)}
      end
      update_storage_object(user_profile.person_authenticated_key, results) if results[:success]
      
      Rails.logger.debug("#{self.class.name.to_s}.#{__method__}() returns: #{results.to_hash}")
      results
      
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      delete_storage_object(user_profile.person_authenticated_key) unless user_profile.nil?
      results = {
          success: false,
          message: e.message,
          username: "unknown",
          entries:[]
      }
    end

    def collect_context_profile_entry(usrp)
      Secure::AccessRegistry.get_resource_content_entries(usrp.combined_access_roles, usrp.user_options )
    end

  end
end