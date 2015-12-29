##
# app/services/content_profile_service.rb
#
# Manages CP interactions for Users
# - requires Utility::UserContentProfileBean on User instance via User#content_profile

class ContentProfileService < ::Factory::DomainServices

  # attr_accessor :factory, :user, :current_user  -- initialize by service factory


	def some_function(params)
    # do something good
		bean = {
			success: true,
			message: "Did something good."
		}
		SknUtils::PageControls.new(bean)
		
	rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}(#{user.username if user.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
		bean = {
			success: false,
			message: e.message
		}
		SknUtils::PageControls.new(bean)
	end


end
