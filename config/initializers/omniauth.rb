Rails.application.config.middleware.use OmniAuth::Builder do
  private_key_path = ENV['LOGIN_CERT_LOCATION'] || 'config/logindotgov.pem'

  if File.exists?(private_key_path)
    protocol = Rails.env.development? ? 'http://' : 'https://'
    provider :login_dot_gov, {
      name:         :logindotgov,
      client_id:    ENV['LOGIN_CLIENT_ID'],
      idp_base_url: ENV['LOGIN_IDP_BASE_URL'],
      ial:          1,
      private_key:  OpenSSL::PKey::RSA.new(File.read(private_key_path)),
      redirect_uri: "#{protocol}#{ENV['LOGIN_HOST']}/auth/logindotgov/callback"
    }
  end
end
