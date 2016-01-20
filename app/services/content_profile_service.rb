##
# app/services/content_profile_service.rb
#
# Manages CP interactions for Users
# - requires Utility::ContentProfileBean on User instance via User#content_profile

class ContentProfileService < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='content'

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

  def api_accessible_content(params)
    handle_accessible_content_api(params)
  end

  # Controller Entry Point
  def manage_content_profiles(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: handle_profiles_management(params)
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

  def api_content_profiles(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: handle_content_profiles_api(params)
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

end
