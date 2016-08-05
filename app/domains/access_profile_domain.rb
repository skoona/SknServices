##
# app/services/access_profile_domain.rb
#
# Manages user access to this system and its clickables and other resources

class AccessProfileDomain < ::Factory::DomainsBase

  def reload_access_registry
    # hash = Secure::AccessRegistry.get_ar_permissions_hash
    # puts generate_xml_from_hash(hash, 'my_stuff', 'FileDownload/UserGroups/Pdf')
    Secure::AccessRegistry.ar_reload_configuration_file()
  end

  def get_user_form_options
    SknUtils::PageControls.new({
                                   groups: group_select_options,
                                   roles: role_select_options
                               })
  end
  def group_select_options
    UserGroupRole.select_options
  end
  def role_select_options
    UserRole.select_options
  end


  ##
  # generate xml from a hash of hashes or array of hashes
  # generate xml from a regular hash, with/out arrays
  def generate_xml_from_hash(hash, base_type, collection_key)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.send(base_type) { process_simple_array(collection_key, hash, xml) }
    end

    builder.to_xml
  end
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