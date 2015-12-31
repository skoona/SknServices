##
# app/services/content_profile_service.rb
#
# Manages CP interactions for Users
# - requires Utility::UserContentProfileBean on User instance via User#content_profile

class ContentProfileService < ::ProfilesDomain

# attr_accessor :factory, :user, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='content'

  def handle_demo_page(params={})
    @page_user = current_user

    SknUtils::PageControls.new({
       success: true,
       message: "",
       accessible_content_url: factory.controller.page_action_paths(:accessible_content_path),
       page_users: get_page_users,
       page_user: page_user.username,
       content_profile: get_page_content_profile
    })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
        success: false,
        message: e.message,
        page_users: [],
        page_user: "",
        content_profile: []
    })
  end


end
