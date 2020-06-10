require 'spec_helper'

describe '/clicked' do
  let(:endpoint) { '/clicked' }
  let(:valid_params) do
    {
      url: 'https://example.gov',
      query: 'test_query',
      position: '1',
      affiliate: 'test_affiliate',
      vertical: 'test_vertical',
      module_code: 'BWEB'
    }
  end
  let(:click_model) { Click }
  let(:click_mock) { instance_double(click_model, log: nil) }

  before { Rails.application.env_config['HTTP_USER_AGENT'] = 'test_user_agent' }
  after { Rails.application.env_config['HTTP_USER_AGENT'] = 'nil' }

  context 'with valid params' do
    let(:expected_params) do
      valid_params.merge client_ip: '127.0.0.1', user_agent: 'test_user_agent'
    end

    it_behaves_like 'a successful click request'
  end

  context 'with invalid params' do
    let(:invalid_params) do
      {
        url: nil,
        query: nil,
        position: nil,
        affiliate: nil,
        vertical: nil,
        module_code: nil
      }
    end
    let(:expected_error_msg) do
      "[\"Url can't be blank\",\"Query can't be blank\","\
      "\"Position can't be blank\",\"Module code can't be blank\"]"
    end

    it_behaves_like 'an unsuccessful click request'
  end

  it_behaves_like 'does not accept GET requests'
  it_behaves_like 'drops urls with invalid utf-8'
end
