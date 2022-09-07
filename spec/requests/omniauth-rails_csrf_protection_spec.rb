# frozen_string_literal: true

# Make sure that https://nvd.nist.gov/vuln/detail/CVE-2015-9284 is mitigated
# https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
RSpec.describe 'CVE-2015-9284' do
  describe 'POST /auth/:provider without CSRF token' do
    before do
      @allow_forgery_protection = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      @omni_auth_test_mode = OmniAuth.config.test_mode
      OmniAuth.config.test_mode = false
      @omni_auth_on_failure = OmniAuth.config.on_failure
      OmniAuth.config.on_failure = proc { raise 'test auth failure!' }
    end

    after do
      ActionController::Base.allow_forgery_protection = @allow_forgery_protection
      OmniAuth.config.test_mode = @omni_auth_test_mode
      OmniAuth.config.on_failure = @omni_auth_on_failure
    end

    it 'fails' do
      expect { post '/auth/logindotgov' }.to raise_error('test auth failure!')
    end
  end
end
