class TestEmailInterceptor
  def self.delivering_email(message)
    message.to = ['appdev@localhost.com']
    message.subject = "[SknServices Test Email] #{message.subject}"
  end
end