require 'spec_helper'

describe '/api/v2/click' do
  let(:endpoint) { '/api/v2/click' }
  let(:valid_params) do
    {
      url: 'https://search.gov',
      query: 'test_query',
      client_ip: '127.0.0.1',
      position: '1',
      affiliate: 'nps.gov',
      vertical: 'test_vertical',
      module_code: 'BWEB',
      user_agent: 'test_user_agent',
      access_key: 'basic_key'
    }
  end
  let(:click_model) { ApiClick }
  let(:click_mock) { instance_double(click_model, log: nil) }

  context 'with valid params' do
    let(:expected_params) { valid_params }

    it_behaves_like 'a successful click request'
  end

  context 'invalid access_key' do
    it 'returns an error message' do
      valid_params['access_key'] = 'invalid'

      post endpoint, params: valid_params

      expect(response.status).to eq 401
      expect(response.body).to eq('["Access key is invalid"]')
    end
  end

  context 'with invalid params' do
    let(:invalid_params) do
      {
        url: nil,
        query: nil,
        client_ip: nil,
        position: nil,
        affiliate: nil,
        vertical: nil,
        module_code: nil,
        user_agent: nil,
        access_key: nil
      }
    end
    let(:expected_error_msg) do
      "[\"Url can't be blank\",\"Query can't be blank\","\
      "\"Position can't be blank\",\"Module code can't be blank\","\
      "\"Client ip can't be blank\",\"User agent can't be blank\","\
      "\"Affiliate can't be blank\",\"Access key can't be blank\"]"
    end

    it_behaves_like 'an unsuccessful click request'
  end

  it_behaves_like 'does not accept GET requests'
  it_behaves_like 'drops urls with invalid utf-8'
end
