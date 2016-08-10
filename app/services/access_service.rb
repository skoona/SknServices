##
# app/services/access_service.rb
#
# Manages

class AccessService < ::AccessProfileDomain

  PROFILE_CONTEXT='access'

  # Users Controller Methods
  def handle_users_index
    result = { counter: 0,
               users: User.paginate(page: params[:page], :per_page => 16)
    }

    if current_user_has_create?('users/new')
      result.store(:package, {page_actions: [{ id: "new-user", path: new_user_path, text: "User", icon: 'glyphicon-plus'}]})
    end
    @page_controls = SknUtils::PageControls.new(result)
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
    bean = {
        success: true,
        user: user,
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
    usr = User.find_by(username: params[:user][:username])
    raise Utility::Errors::InvalidCredentialError, "Sorry, your username cannot be found." if usr.nil?
    send_password_reset(usr)
    bean = {
        success: true,
        user: usr,
        message: "Email sent with password reset instructions"
    }
    SknUtils::ResultBean.new(bean)
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}(#{usr.username if usr.present?}) Klass: #{e.class.name}, Cause: #{e.message}"
    SknUtils::ResultBean.new({
        success: false,
        message: e.message
    })
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

  ##
  # Pages Controller Methods
  ##

  def handle_system_information_api(params)
    msg = case params['id']
      when 'xml'
        reload_access_registry
        "AccessRegistry Reloaded"
      when 'purge'
        count = service.purge_storage_objects((Time.now - 10.minutes).to_i)
        "ObjectStorageContainer Purged #{count} Items"
    end
    SknUtils::PageControls.new({
                                   success: true,
                                   message: msg
                               })
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}(#{params[:id]}) Klass: #{e.class.name}, Cause: #{e.message}, stack: #{e.backtrace[0..8]}"
    SknUtils::PageControls.new({
        success: false,
        message: e.message
    })
  end

  def handle_system_information(params)

    SknUtils::PageControls.new( generate_system_info_bundle )

  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message}, stack: #{e.backtrace[0..8]}"
    SknUtils::PageControls.new({
        success: false,
        message: e.message,
        authenticated_user: false,
        apis_enabled: false,
        ar_resource_type: 0,
        ar_data_type: 0,
        resource_entries: [],
        content_entries: []
    })
  end


end