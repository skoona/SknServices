##
# app/services/content_profile_service.rb
#
# Manages CP interactions for Users
# - requires Utility::ContentProfileBean on User instance via User#content_profile

class ContentProfileService < ::ProfilesDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='content'

  def handle_content_profile_destroy(content_profile_object)
    SknUtils::ResultBean.new({
                                 success: true,
                                 message: 'Content profile was successfully destroyed.',
                                 content_profile: access_services.destroy_content_profile(content_profile_object)
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
                                 success: false,
                                 message: e.message,
                                 content_profile: nil
                             })
  end

  def handle_content_profile_update(content_profile_object, permitted_params)
    SknUtils::ResultBean.new({
                                 success: true,
                                 message: 'Content profile was successfully updated.',
                                 content_profile: access_services.update_content_profile_from_permitted_params(content_profile_object, permitted_params)
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
                                 success: false,
                                 message: e.message,
                                 content_profile: nil
                             })
  end

  def handle_content_profile_creations(permitted_params)
    SknUtils::ResultBean.new({
                                 success: true,
                                 message: 'Content profile was successfully created.',
                                 content_profile: access_services.create_content_profile_from_permitted_params(permitted_params)
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
                                 success: false,
                                 message: e.message,
                                 content_profile: nil
                             })
  end

  def handle_content_profile_index(params)
    SknUtils::ResultBean.new({
                                  success: true,
                                  message: "",
                                  content_profiles: access_services.get_page_pagination_for_content_profile_index(params)
                               })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::ResultBean.new({
                                   success: false,
                                   message: e.message,
                                   content_profiles: []
                               })
  end

  def show_and_edit_content_profile(content_profile_object)
    SknUtils::PageControls.new({
                                success: true,
                                message: "",
                                content_profile: content_profile_object,
                                content_profile_entries: access_services.get_content_profiles_entries_entry_info(content_profile_object)
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                   success: false,
                                   message: e.message
                               })
  end

  def make_new_content_profile
    SknUtils::ResultBean.new({  # because we don't need deep nesting, or leave array hashes alone
       success: true,
       message: "",
       pak_user_choices: access_services.get_unassigned_user_attributes(),
       content_profile: access_services.get_empty_new_content_profile()
    })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
       success: false,
       message: e.message
   })
  end



  # Controller Entry Point
  def handle_demo_page(params={})
    SknUtils::PageControls.new({
       success: true,
       message: "",
       page_users: get_page_users(PROFILE_CONTEXT)
    })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
        success: false,
        message: e.message,
        page_users: []
    })
  end

  # Controller Entry Point
  def api_accessible_content(params)
    handle_accessible_content_api(params)
  end

  # Controller Entry Point
  def manage_content_profiles(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: handle_profiles_management(params)
    })
    res.success = res.package.success
    res.message = res.package.message
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
       success: false,
       message: e.message,
       package: []
    })
  end

  # Controller Entry Point
  def api_content_profiles(params)
    res = SknUtils::PageControls.new({
       success: true,
       message: "",
       package: handle_content_profiles_api(params)
    })
    res.success = res.package.success
    res.message = res.package.message
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
       success: false,
       message: e.message,
       package: []
    })
  end

end
