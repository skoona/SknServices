##
# app/strategy/use_cases/password_reset_use_case.rb
#
# Manages
module UseCases

  class PasswordResetUseCase < UseCaseBase

    def empty_user_to_get_username
      user = User.new
      SknUtils::NestedResult.new({
         success: user.present?,
         user: user,
         message: ""
      })
    rescue => e
      SknUtils::NestedResult.new({success: false, user: nil, message: e.message})
    end

    def edit_new_password(uid)
      user = User.find_by(password_reset_token: uid)
      SknUtils::NestedResult.new({
          success: user.present?,
          user: user,
          message: ""
      })
    rescue => e
      SknUtils::NestedResult.new({success: false, user: nil, message: e.message})
    end

    def reset_password(params)
      user = User.find(params[:id])  # id is a :password_reset_token
      if user.password_reset_date > 2.hours.ago       # MEANS LESS THAN TWO HOURS AGO
        user.regenerate_remember_token!
        params.merge({user: {remember_token: user.remember_token,remember_token_digest: user.remember_token_digest}})
        user.update!(permitted(params))
      else
        raise Utility::Errors::ExpiredCredentialError, "Sorry, your password reset token has expired."
      end
      SknUtils::NestedResult.new({
          success: true,
          user: user,
          message: "Password has been reset please sign in"
      })
    rescue Exception => e
      Rails.logger.error "#{self.class.name}.#{__method__}(#{user.username if user.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
      SknUtils::NestedResult.new({success: false, user: user, message: e.message})
    end

    def reset_requested(params)
      usr = User.find_by(username: params[:user][:username])
      raise Utility::Errors::InvalidCredentialError, "Sorry, your username cannot be found." if usr.nil?
      send_password_reset(usr)
      SknUtils::NestedResult.new({
          success: send_password_reset(usr),
          user: usr,
          message: "Email sent with password reset instructions"
      })
    rescue Exception => e
      Rails.logger.warn "#{self.class.name}.#{__method__}(#{usr.username if usr.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
      SknUtils::NestedResult.new({success: false, message: e.message})
    end


    # Protected from Here

    def permitted(params)
      params.required(:user).permit(:password_confirmation, :password,
                                    :remember_token, :remember_token_digest)
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
end
