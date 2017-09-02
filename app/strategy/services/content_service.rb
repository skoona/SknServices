##
# app/strategy.services/content_service.rb
#
# Manages CP Demo Features
# Manages CP interactions for Users
# - requires Utility::ContentProfileBean on User instance via User#content_profile
module Services

  class ContentService < Domains::ContentProfileDomain

  # attr_accessor :registry, :current_user, :page_user  -- initialize by DomainService

    PROFILE_CONTEXT='content'

    def handle_runtime_demo

      package = runtime_demo_package
      SknUtils::NestedResult.new({
                                     success: package[:cp].present?,
                                     message: package[:message],
                                     payload: package
                                 })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     payload: []
                                 })
    end

    # Controller Entry Point
    def handle_demo_page(params={})

      package = get_page_users(PROFILE_CONTEXT)
      SknUtils::NestedResult.new({
                                     success: package.present?,
                                     message: "",
                                     page_users: package
                                 })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     page_users: []
                                 })
    end


    # Controller Entry Point
    def handle_api_accessible_content(params)

      package = handle_accessible_content_api(params)
      SknUtils::NestedResult.new({
                                     package: {
                                         success: package.present?,
                                         message: params[:content_type_description],
                                         content: params[:id],
                                         username: params[:username],
                                         display_name: package[1],
                                         payload: package[0]
                                     }
                                 })
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({package: {
          success: false,
          message: e.message,
          username: "", display_name: "" ,
          content: params[:id],
          payload: []
      }})
    end

    # Controller Entry Point
    def api_get_content_object(params)

      package = get_content_object_api(params)
      res = SknUtils::NestedResult.new({
                                           success:  package[:success],
                                           message: "",
                                           package: package
                                       })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     package: {}
                                 })
    end

    # Controller Entry Point
    def api_get_demo_content_object(params)

      package = get_demo_content_object_api(params)
      SknUtils::NestedResult.new({
                                           success: package[:success],
                                           message: "",
                                           package: package
                                       })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     package: {}
                                 })
    end

    def handle_members

      package = members_admin_package
      SknUtils::NestedResult.new({
                                     success: package[:success],
                                     message: package[:message],
                                     payload: package[:display_groups]
                                 })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     payload: []
                                 })
    end

    def handle_member(params)

      package = member_admin_package(params)
      SknUtils::NestedResult.new({
                                     success: package[:success],
                                     message: package[:message],
                                     payload: package[:display_groups]
                                 })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     payload: []
                                 })
    end

    def handle_member_updates(params)

      package = member_update_package(params)
      SknUtils::NestedResult.new({
                                     success: package[:success],
                                     message: package[:message],
                                     payload: package[:package]
                                 })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     payload: []
                                 })
    end

    # Controller Entry Point
    def handle_content_profile_management(params)

      package = management_page_users_package(PROFILE_CONTEXT)
      SknUtils::NestedResult.new({
                                           success: package.present?,
                                           message: "",
                                           page_actions: [{
                                              path: :manage_content_profiles_profiles_path,
                                              text: "Refresh",
                                              icon: 'fa fa-refresh',
                                              html_options: {
                                                  id: "refresh-action",
                                                  class: ' refresh'
                                              }
                                           }]
                                       }.merge( package )
      )
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: e.message,
                                     package: []
                                 })
    end

    def handle_content_profile_create(params)

      package = create_content_profile_with_profile_type_id(params)
      SknUtils::NestedResult.new({
                                   success: package,
                                   message: 'Content Profile was successfully created.'
                               })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                   success: false,
                                   message: "create ContentProfile failed. Msg: #{e.class.name}"
                               })
    end

    def handle_content_profile_update(params)

      package = update_content_profile_with_profile_type_id(params)
      SknUtils::NestedResult.new({
                                   success: package,
                                   message: 'Content profile was successfully updated.'
                               })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                   success: false,
                                   message: e.message
                               })
    end

    def handle_content_profile_destroy(params)

      package = destroy_content_profile_by_pak(params)
      SknUtils::NestedResult.new({
                                   success: package,
                                   message: 'Content profile was successfully destroyed.'
                               })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                   success: false,
                                   message: e.message
                               })
    end

    # POST
    def handle_content_profile_entries_create(params)

      raise Utility::Errors::IncompleteSelectionFailure, "Please make Topic and/or Content selection!" unless params['topic_type_value']
      package = create_content_profile_entries(params)
      SknUtils::NestedResult.new({
                                  success: package,
                                  message: 'Content profile entry was successfully created.'
                               })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                     success: false,
                                     message: "[ #{e.class.name} ] create ContentProfileEntry failed. Msg: #{e.message}"
                                 })
    end

    # POST
    def handle_content_profile_entry_destroy(params)

      package = destroy_content_profile_entry(params)
      SknUtils::NestedResult.new({
                                   success: package,
                                   message: package ?
                                       'Destroy Content profile entry was successfully' :
                                       'Destroy Content profile entry failed!'
                               })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
      SknUtils::NestedResult.new({
                                   success: false,
                                   message: e.message
                               })
    end

  end
end
