
##
# Special Performance Tracker
# Ref: http://blog.mmlac.com/log4r-for-rails/
#      http://www.paperplanes.de/2012/3/14/on-notifications-logsubscribers-and-bringing-sanity-to-rails-logging.html
#
# Notification Publish/Interceptors
#      vendor/bundle/gems/actionpack-4.2.5/lib/action_controller/metal/instrumentation.rb
#      vendor/bundle/gems/actionpack-4.2.5/lib/action_controller/log_subscriber.rb
##
# To intercept at the Rack Level try: 'request.action_dispatch'
# - change payload[:action] to payload[:path], else nil error

## REQUEST Begining Event 'start_processing.action_controller', Not Needed
## REQUEST Ending Event
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|

  controller_format = %Q(EventID=@id RequestId=@uuid @method @action @status Duration:@durationms Logic:@logicms DB:@dbms View:@viewms User:@username Params:@requestparams)
  db = (payload[:db_runtime] * 100).round / 100.0 rescue 0
  view = (payload[:view_runtime] * 100).round / 100.0 rescue 0
  duration = ( ((finish - start).to_f * 100000).round / 100.0 rescue 0)
  logic = "%2.2f" % (duration - (db + view))

  Rails.logger.perf {
    message = controller_format.clone
    message.sub!(/@id/, id)
    message.sub!(/@uuid/,  payload.fetch(:uuid, 'na'))
    message.sub!(/@method/, payload[:method])
    message.sub!(/@action/, "#{payload[:controller]}##{payload[:action]}")
    message.sub!(/@status/, payload[:status].to_s)
    message.sub!(/@duration/, '%2.2f' % duration)
    message.sub!(/@logic/, logic)
    message.sub!(/@db/, '%2.2f' % db)
    message.sub!(/@view/, '%2.3f' % view)
    message.sub!(/@username/, payload.fetch(:username,'no-user'))
    message.sub!(/@requestparams/, payload.fetch(:params,'none').inspect )

    if payload[:exception].present? || payload[:status] == 500
      message += " EXCEPTION: #{payload[:exception]}"
    end

    message
  }

end
