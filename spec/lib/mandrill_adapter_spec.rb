require 'spec_helper'

describe MandrillAdapter do
  subject(:adapter) { described_class.new(config) }

  let(:user) { mock_model(User) }

  describe '.new' do
    let(:config) { { some: 'config' } }

    its(:config) { should == config }
  end

  describe '#smtp_settings' do
    let(:config) do
      {
        some: 'config',
        api_username: api_username,
        api_key: api_key,
      }
    end

    context 'when there is no api_username or api_key in the config' do
      let(:api_username) { nil }
      let(:api_key) { nil }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is an api_username but no api_key in the config' do
      let(:api_username) { 'username' }
      let(:api_key) { nil }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is an api_key but no api_username in the config' do
      let(:api_username) { nil }
      let(:api_key) { 'key' }

      its(:smtp_settings) { should be_nil }
    end

    context 'when there is both an api_username and api_key in the config' do
      let(:api_username) { 'configured_username' }
      let(:api_key) { 'configured_key' }

      its(:smtp_settings) do
        should eq({
          address: 'smtp.mandrillapp.com',
          port: 587,
          enable_starttls_auto: true,
          user_name: 'configured_username',
          password: 'configured_key',
          authentication: 'login',
        })
      end
    end
  end
end
