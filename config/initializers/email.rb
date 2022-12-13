# frozen_string_literal: true

Rails.application.config.to_prepare do
  email_config = Rails.application.secrets.email || { }

  if action_mailer_config = email_config[:action_mailer]
    action_mailer_config.each do |name, value|
      value.symbolize_keys! if value.instance_of?(Hash)
      ActionMailer::Base.send("#{name}=", value)
    end
  end

  force_to = email_config[:force_to]
  Emailer.register_interceptor(SearchGovInterceptor.new(force_to))
end
