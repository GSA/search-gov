Rails.application.config.middleware.use OmniAuth::Builder do
  provider :login_dot_gov, {
    client_id: 'urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:search',
    idp_base_url: 'https://idp.int.identitysandbox.gov',
    ial: 1,
    private_key: OpenSSL::PKey::RSA.new(File.read('config/search.pem')),
    redirect_uri: 'http://localhost:3000/auth/logindotgov/callback'
  }
end