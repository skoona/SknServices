##
#
# Inherited by: ContentProfileService, AccessProfileService
#
#

class ProfilesDomain < ::Factory::DomainServices



  PROFILE_CONTEXT=""  # override in service

  def accessible_content(params)
    get_page_user(params[:username])
    @accessible_type = params[:access] # [:access, :content]
    results = case @accessible_type
                when 'access'
                  {success: true, message: "", content: 'access'}
                when 'content'
                  {success: true, message: "", content: 'content'}
                else
                  {success: false, message: "not found"}
              end
    SknUtils::ResultBean.new(results)

  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
                                 success: false,
                                 message: e.message,
                                 content: @accessible_type
                             })
  end

  def get_page_users(context=PROFILE_CONTEXT)
    usrs = []
    Secure::UserProfile.page_users.each do |u|
      usrs << {username: u.last, display_name: u.first}
    end
    usrs
  end
  def get_user_form_options
    SknUtils::PageControls.new({
                                   groups: group_select_options,
                                   roles: role_select_options
                               })
  end

  def get_page_user(uname, context=PROFILE_CONTEXT)
    @page_user = Secure::UserProfile.page_user(uname)
  end

  def get_page_access_profile
    page_user.access_profile(true)
  end

  def get_page_content_profile
    page_user.content_profile.to_hash
  end

  def group_select_options
    UserGroupRole.all().map do |r|
      [r.description, r.name]
    end
  end
  def role_select_options
    UserRole.all().map do |r|
      [r.description, r.name]
    end
  end

  def page_user
    @page_user || current_user
  end
  def page_user=(obj)
    @page_user = obj
  end

end