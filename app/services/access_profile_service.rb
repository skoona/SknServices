##
# app/services/content_profile_service.rb
#
# Manages Secure::AccessRegistry interactions for Users
# - Requires User#access_profile

class AccessProfileService < ::ProfilesDomain

  # attr_accessor :factory, :user, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='access'

  def handle_demo_page(params={})
    # access_profile_package(params[:username])

    pg_u = @page_user = current_user

    SknUtils::PageControls.new({
       success: true,
       message: "",
       accessible_content_url: factory.controller.page_action_paths([:accessible_content_path, {id: PROFILE_CONTEXT}]),
       page_users: get_page_users,
       page_user: pg_u.username,
       access_profile: get_page_access_profile(pg_u)
    })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
        success: false,
        message: e.message,
        page_users: [],
        page_user: "",
        access_profile: []
    })
  end



end
