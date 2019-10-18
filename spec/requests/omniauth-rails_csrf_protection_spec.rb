# Make sure that https://nvd.nist.gov/vuln/detail/CVE-2015-9284 is mitigated
RSpec.describe 'CVE-2015-9284' do
  describe 'POST /auth/:provider without CSRF token' do
    before do
      @allow_forgery_protection = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
    end

    after do
      ActionController::Base.allow_forgery_protection = @allow_forgery_protection
    end

    it do
      expect {
        post '/auth/logindotgov'
      }.to raise_error(ActionController::InvalidAuthenticityToken)
    end
  end
end
