# frozen_string_literal: true

Rails.application.config.to_prepare do
  interceptor = SearchGovInterceptor.new(ENV['MAIL_FORCE_TO'] || Rails.application.secrets.email)

  Emailer.register_interceptor(interceptor)
end
