##
# app/services/profiles_service.rb
#
# Manages Sumary Demo Features
# - requires Utility::ContentProfileBean on User instance via User#content_profile

class ProfileService < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='content'

  # Controller Entry Point
  def handle_demo_page(params={})
    SknUtils::PageControls.new({
       success: true,
       message: "",
       page_users: get_page_users(PROFILE_CONTEXT)
    })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
        success: false,
        message: e.message,
        page_users: []
    })
  end


  # Controller Entry Point
  def handle_api_accessible_content(params)
    payload = handle_accessible_content_api(params)
    SknUtils::PageControls.new({
      package: {
        success: true,
        message: params[:content_type_description],
        content: params[:id],
        username: params[:username],
        display_name: payload[1],
        payload: payload[0]
      }
    })
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({package: {
        success: false,
        message: e.message,
        username: "", display_name: "" ,
        content: params[:id],
        payload: []
    }})
  end

  # Controller Entry Point
  def handle_content_profile_management(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: management_page_users_package(PROFILE_CONTEXT)
    })
    res.success = res.package.success
    res.message = res.package.message
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
       success: false,
       message: e.message,
       package: []
    })
  end

  # Controller Entry Point
  def api_get_content_object(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: get_content_object_api(params)
    })
    res.success = res.package.success
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
       success: false,
       message: e.message,
       package: {}
    })
  end

end
