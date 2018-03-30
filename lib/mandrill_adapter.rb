class MandrillAdapter
  class NoClient < StandardError; end
  class UnknownTemplate < StandardError; end

  attr_reader :config

  ENVIRONMENT_CONFIG = Rails.application.secrets.mandrill

  def initialize(config=nil)
    @config = config || ENVIRONMENT_CONFIG
  end

  def smtp_settings
    if config[:api_username] && config[:api_key]
      {
        address: 'smtp.mandrillapp.com',
        port: 587,
        enable_starttls_auto: true,
        user_name: config[:api_username],
        password: config[:api_key],
        authentication: 'login',
      }
    end
  end

  def bcc_setting
    config[:bcc_email]
  end
end
