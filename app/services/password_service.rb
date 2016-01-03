class PasswordService < ::Factory::DomainServices

	# attr_accessor :factory, :user, :current_user  -- initialize by service factory

	def reset_password(params)
		user = User.find(params[:id])  # id is a :password_reset_token
		if user.password_reset_date > 2.hours.ago       # MEANS LESS THAN TWO HOURS AGO
       user.regenerate_remember_token!
       params.merge({user: {remember_token: user.remember_token,remember_token_digest: user.remember_token_digest}})
			 user.update!(permitted(params))
		else
		  raise Utility::Errors::ExpiredCredentialError, "Sorry, your password reset token has expired."  
		end			 
		bean = {
			success: true,
			message: "Password has been reset please sign in"
		}
		SknUtils::ResultBean.new(bean)
		
	rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}(#{user.username if user.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
		bean = {
			success: false,
			user: user,
			message: e.message
		}
		SknUtils::ResultBean.new(bean)	
	end

  def permitted(params)
    params.required(:user).permit(:password_confirmation, :password,
                                  :remember_token, :remember_token_digest)
  end

	def reset_requested(params)
		user = User.find_by(username: params[:user][:username])
    raise Utility::Errors::InvalidCredentialError, "Sorry, your username cannot be found." if user.nil?
		send_password_reset(user) if user
		bean = {
			success: true,
			message: "Email sent with password reset instructions"
		}
		SknUtils::ResultBean.new(bean)
	rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}(#{user.username if user.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
		bean = {
			success: false,
			message: "Email sent with password reset instructions"
		}
		SknUtils::ResultBean.new(bean)
	end

  def send_password_reset(user)
    user.generate_unique_token(:password_reset_token)
    user.regenerate_remember_token!
    user.password_reset_date = Time.zone.now
    user.save!
    password_mailer(user)
  end

  def password_mailer(user)
    UserMailer.password_reset(user).deliver_now
  end

end
