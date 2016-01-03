##
# app/services/content_profile_service.rb
#
# Manages Secure::AccessRegistry interactions for Users
# - Requires User#access_profile

class AccessProfileService < ::ProfilesDomain

  # attr_accessor :factory, :user, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='access'

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

  def accessible_content(params)
    api_accessible_content(params)
  end

end
