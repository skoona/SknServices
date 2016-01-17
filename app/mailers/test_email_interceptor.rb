class TestEmailInterceptor
  def self.delivering_email(message)
    message.to = ['appdev@brotherhoodmutual.com']
    message.subject = "[XD Test Email] #{message.subject}"
  end
end