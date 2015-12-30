##
# app/services/content_profile_service.rb
#
# Manages Secure::AccessRegistry interactions for Users
# - Requires User#access_profile

class AccessProfileService < ::ContentProfileDomain

  # attr_accessor :factory, :user, :current_user  -- initialize by service factory

  def handle_demo_page(params={})
    @page_user=current_user

    SknUtils::PageControls.new({
                                   success: true,
                                   message: "",
                                   page_users: get_page_users,
                                   page_user: page_user.username,
                                   content_profile: get_page_content_profile,
                                   access_profile: get_page_access_profile
                               })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
        success: false,
        message: e.message,
        page_users: [],
        page_user: "",
        content_profile: [],
        access_profile: []
    })
  end



end
