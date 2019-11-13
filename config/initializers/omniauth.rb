Rails.application.config.middleware.use OmniAuth::Builder do
  provider :login_dot_gov, {
    name: :logindotgov,
    client_id: Rails.application.secrets.login_dot_gov['client_id'],
    idp_base_url: Rails.application.secrets.login_dot_gov['idp_base_url'],
    ial: 1,
    private_key: OpenSSL::PKey::RSA.new(File.read('config/logindotgov.pem')),
    redirect_uri: "http://#{Rails.application.secrets.login_dot_gov['host']}/auth/logindotgov/callback"
  }
end
