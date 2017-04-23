ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
	:address				=> "smtp.gmail.com",
	:port					=> 587,
	:domain				=> "localhost.domain",
	:user_name				=> "someuserid",
	:password				=> "somepassword",
	:authentication			=> "plain",
	:enable_starttls_auto		=> true
}
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.register_interceptor(Utility::DevelopmentMailInterceptor) unless Rails.env.production?


#
# ActionMailer::Base.smtp_settings = {
#     address:              'smtp01.localhost.com',
#     enable_starttls_auto: true
# }
#

# ActionMailer::Base.register_interceptor(TestEmailInterceptor) unless Settings.Packaging.isProduction
# ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.test?
# Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.test?
