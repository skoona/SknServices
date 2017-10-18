##
# app/strategy.services/access_service.rb
#
# Manages
module Services

  class AccessService < Domains::AccessProfileDomain

    PROFILE_CONTEXT='access'

    ##
    # Users Controller Methods
    ##

    def get_user_form_options
      
      SknUtils::NestedResult.new({
         groups: group_select_options,
         roles: role_select_options
      })
    end

    def handle_users_index(params)
      
      result = { counter: 0,
                 users: User.paginate(page: params[:page], :per_page => 16)
      }

      if current_user_has_create?('users/new')
        result.store(:package, {page_actions: [{ id: "new-user", path: new_user_path, text: "User", icon: 'glyphicon-plus'}]})
      end
      @page_controls = SknUtils::NestedResult.new(result)
    end

    ##
    # Pages Controller Methods
    ##

    def handle_system_information_api(params)
      
      package = system_actions_api(params)
      SknUtils::NestedResult.new({
                                     success: package.present?,
                                     message: package
                                 })
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}(#{params['id']}) Klass: #{e.class.name}, Cause: #{e.message}, stack: #{e.backtrace[0..8]}"
      SknUtils::NestedResult.new({
          success: false,
          message: e.message
      })
    end

    def handle_system_information(params)
      
      package = generate_system_info_bundle
      SknUtils::NestedResult.new( package )

    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message}, stack: #{e.backtrace[0..8]}"
      SknUtils::NestedResult.new({
          success: false,
          message: e.message,
          authenticated_user: false,
          apis_enabled: false,
          ar_resource_type: 0,
          ar_data_type: 0,
          resource_entries: [],
          content_entries: []
      })
    end

  end
end
