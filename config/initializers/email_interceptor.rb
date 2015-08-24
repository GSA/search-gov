require 'mandrill_adapter'

class UsasearchEmailInterceptor
  class << self
    attr_accessor :force_to
  end

  def self.delivering_email(message)
    message.to = [ force_to ]
  end
end


if force_to = MandrillAdapter.new.force_to
  UsasearchEmailInterceptor.force_to = force_to
  Emailer.register_interceptor(UsasearchEmailInterceptor)
end
