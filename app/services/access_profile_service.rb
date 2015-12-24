##
# app/services/content_profile_service.rb
#
# Manages AccessRegistry interactions for Users
# - Requires User#access_profile

class AccessProfileService < ::Factory::DomainServices

  # attr_accessor :factory, :user, :current_user  -- initialize by service factory


  def get_user_form_options
    SknUtils::PageControls.new({
        groups: group_select_options,
        roles: role_select_options
                               })
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
	def some_function(params)
    # do something good
		bean = {
			success: true,
			message: "Did something good."
		}
		SknUtils::ResultBean.new(bean)
		
	rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}(#{user.username if user.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
		bean = {
			success: false,
			message: e.message
		}
		SknUtils::ResultBean.new(bean)	
	end


end
