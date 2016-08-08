##
# app/services/content_service.rb
#
# Manages CP Demo Features
# Manages CP interactions for Users
# - requires Utility::ContentProfileBean on User instance via User#content_profile

class ContentService < ::ContentProfileDomain

# attr_accessor :factory, :current_user, :page_user  -- initialize by DomainService

  PROFILE_CONTEXT='content'


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
  def handle_api_accessible_content(params)
    payload = handle_accessible_content_api(params)
    SknUtils::PageControls.new({
                                   package: {
                                       success: true,
                                       message: params[:content_type_description],
                                       content: params[:id],
                                       username: params[:username],
                                       display_name: payload[1],
                                       payload: payload[0]
                                   }
                               })
  rescue Exception => e
    Rails.logger.warn "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({package: {
        success: false,
        message: e.message,
        username: "", display_name: "" ,
        content: params[:id],
        payload: []
    }})
  end

  # Controller Entry Point
  def api_get_content_object(params)
    res = SknUtils::PageControls.new({
                                         success: true,
                                         message: "",
                                         package: get_content_object_api(params)
                                     })
    res.success = res.package.success
    res
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                   success: false,
                                   message: e.message,
                                   package: {}
                               })
  end

  # Controller Entry Point
  def handle_content_profile_management(params)
    res = SknUtils::PageControls.new({
                                         success: true,
                                         message: "",
                                         profile_type_options: ProfileType.option_selects,
                                         content_type_options: ContentType.option_selects,
                                         content_type_opts_options: ContentTypeOpt.option_selects('Commission'),
                                         topic_type_options: TopicType.option_selects,
                                         topic_type_opts_options: TopicTypeOpt.option_selects('Branch'),
                                         package: management_page_users_package(PROFILE_CONTEXT)
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

  def handle_content_profile_create(params)
    SknUtils::PageControls.new({
                                 success: create_content_profile_with_profile_type_id(params),
                                 message: 'Content Profile was successfully created.'
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                 success: false,
                                 message: "create ContentProfile failed. Msg: #{e.class.name}"
                             })
  end

  def handle_content_profile_update(params)
    SknUtils::PageControls.new({
                                 success: update_content_profile_with_profile_type_id(params),
                                 message: 'Content profile was successfully updated.'
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                 success: false,
                                 message: e.message
                             })
  end

  def handle_content_profile_destroy(params)
    SknUtils::PageControls.new({
                                 success: destroy_content_profile_by_pak(params),
                                 message: 'Content profile was successfully destroyed.'
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                 success: false,
                                 message: e.message
                             })
  end

  # Parameters: {"utf8"=>"✓",
  #   "id"=>"profile entry id",
  #   "pak"=>"72930134e6222904010dd4d6fb5f1887",
  #   "username"=>"bptester",
  #   "description_id"=>"Samples",
  #   "topic_type_id"=>"1",
  #   "topic_type_value"=>["1"],
  #   "content_type_id"=>"3",
  #   "content_type_value"=>["9", "8", "7"],
  #   "button"=>"content-entry-modal"
  # }
  #
  # POST
  def handle_content_profile_entries_create(params)
    SknUtils::PageControls.new({
                                success: create_content_profile_entries(params),
                                message: 'Content profile entry was successfully created.'
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                   success: false,
                                   message: e.message
                               })
  end

  def handle_content_profile_entry_destroy(params)
    SknUtils::PageControls.new({
                                 success: destroy_content_profile_entry(params),
                                 message: 'Content profile entry was successfully destroyed.'
                             })
  rescue Exception => e
    Rails.logger.error "#{self.class.name}.#{__method__}() Klass: #{e.class.name}, Cause: #{e.message} #{e.backtrace[0..4]}"
    SknUtils::PageControls.new({
                                 success: false,
                                 message: e.message
                             })
  end

end
