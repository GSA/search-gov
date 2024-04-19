# frozen_string_literal: true

Rails.application.config.to_prepare do
  interceptor = SearchGovInterceptor.new(ENV['MAIL_FORCE_TO'] || Rails.application.secrets.dig(:email, :force_to))

  Emailer.register_interceptor(interceptor)
end
