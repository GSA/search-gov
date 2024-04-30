Rails.application.config.middleware.use OmniAuth::Builder do
  protocol = Rails.env.development? ? 'http://' : 'https://'

  provider :login_dot_gov, {
    name:         :logindotgov,
    client_id:    ENV['LOGIN_CLIENT_ID'] || Rails.application.secrets.dig(:login_dot_gov, :client_id),
    idp_base_url: ENV['LOGIN_IDP_BASE_URL'] || Rails.application.secrets.dig(:login_dot_gov, :idp_base_url),
    ial:          1,
    private_key:  ENV['LOGIN_CERT'] || OpenSSL::PKey::RSA.new(File.read('config/logindotgov.pem')),
    redirect_uri: "#{protocol}#{ENV['LOGING_HOST'] || Rails.application.secrets.dig(:login_dot_gov, :host)}/auth/logindotgov/callback"
  }
end
