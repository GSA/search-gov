SearchGovInterceptor = Struct.new(:force_to) do
  def delivering_email(message)
    message.to = [force_to]
  end
end

email_config = Rails.application.secrets.email || { }

if action_mailer_config = email_config[:action_mailer]
  action_mailer_config.each do |name, value|
    value.symbolize_keys! if value.instance_of?(Hash)
    ActionMailer::Base.send("#{name}=", value)
  end
end

if force_to = email_config[:force_to]
  Emailer.register_interceptor(SearchGovInterceptor.new(force_to))
end
