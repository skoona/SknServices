##
# app/strategy.services/access_profile_domain.rb
#
# Manages user access to this system and its clickables and other resources

module Domains

  class AccessProfileDomain < DomainsBase

    def reload_access_registry
      # hash = Secure::AccessRegistry.get_ar_permissions_hash
      # puts generate_xml_from_hash(hash, 'my_stuff', 'FileDownload/UserGroups/Pdf')
      Secure::AccessRegistry.ar_reload_configuration_file()
    end

    def group_select_options
      UserGroupRole.select_options
    end
    def role_select_options
      UserRole.select_options
    end

    def system_actions_api(params)
      case params['id']
        when 'xml'
          reload_access_registry
          "AccessRegistry Reloaded"
        when 'purge'
          count =purge_storage_objects((Time.zone.now - 10.minutes).to_i)
          "ObjectStorageContainer Purged #{count} Items"
      end
    end

    def generate_system_info_bundle
      ar_resource_type = ar_data_type = 0
      resource_entries = []
      content_entries = []
      c_count = 0
      r_count = 0
      Secure::AccessRegistry.get_ar_resource_keys.each do |ar|

        if Secure::AccessRegistry.get_resource_type(ar)
          ar_data_type += 1
          content_entries << {
              index: '%04d' % (c_count += 1),
              uri: ar.to_s,
              description: Secure::AccessRegistry.get_resource_description(ar),
              options: Secure::AccessRegistry.get_resource_options(ar),
              userdata: Secure::AccessRegistry.get_resource_userdata(ar)
          }
        else
          ar_resource_type += 1
          resource_entries << {
              index: '%04d' % (r_count += 1),
              uri: ar.to_s,
              description: Secure::AccessRegistry.get_resource_description(ar),
              roles: Secure::AccessRegistry.get_resource_roles(ar)
          }
        end

      end

      authenticated_user = (current_user.present? ? true : false )
      xprofile =xml_profile_provider.content_profile_for_user(current_user)
      cprofile =db_profile_provider.content_profile_for_user(current_user)
      storage_size = Secure::ObjectStorageContainer.instance.size_of_store('Admin')
      storage_keys = Secure::ObjectStorageContainer.instance.list_storage_keys_and_value_class

      result = {
         success: true,
         message: nil,
         authenticated_user: authenticated_user,
         username: (authenticated_user ? current_user.name : 'No authenticated user.'),
         ar_resource_type: ar_resource_type,
         ar_data_type: ar_data_type,
         resource_entries: resource_entries,
         content_entries: content_entries,
         xprofile: xprofile,
         cprofile: cprofile,
         apis_enabled: (authenticated_user and current_user.has_access?('#Management')),
         storage_size: storage_size,
         storage_keys: storage_keys
      }

      result
    end

  end
end
