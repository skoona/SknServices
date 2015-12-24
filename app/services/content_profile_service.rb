##
# app/services/content_profile_service.rb
#
# Manages CP interactions for Users
# - requires Secure::UserContentProfile on User instance via User#content_profile

class ContentProfileService

	attr_accessor :factory, :user

	def initialize(params={})
		[:factory, :user].each do |k|
			send("#{k}=", nil)
			send("#{k}=", params[k]) if params.key?(k)
		end
		raise ArgumentError,
          "ContentProfileService: Initialization param missing (#{'factory' if @factory.nil?} #{'user' if @user.nil?} #{self.class.name})" unless @factory.present? and @user.present?
	end

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
