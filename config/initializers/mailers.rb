
ActionMailer::Base.smtp_settings = {
	:address				=> "smtp.gmail.com",
	:port					=> 587,
	:domain				=> "frontier.com",
	:user_name				=> "jamesscottjr",
	:password				=> "NBH1290a",
	:authentication			=> "plain",
	:enable_starttls_auto		=> true
}

# Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.test?
