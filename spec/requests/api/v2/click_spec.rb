require 'spec_helper'

describe '/api/v2/click' do
  let(:endpoint) { '/api/v2/click' }
  let(:valid_params) do
    {
      url: 'https://search.gov',
      query: 'test_query',
      position: '1',
      affiliate: 'nps.gov',
      vertical: 'test_vertical',
      module_code: 'BWEB',
      access_key: 'basic_key'
    }
  end
  let(:click_model) { ApiClick }
  let(:click_mock) { instance_double(click_model, log: nil) }

  include_context 'when the click request is browser-based'

  it_behaves_like 'a successful click request'

  context 'with authenticty token checking turned on' do
    before do
      ActionController::Base.allow_forgery_protection = true
    end

    it_behaves_like 'a successful click request'

    after do
      ActionController::Base.allow_forgery_protection = false
    end
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
        position: nil,
        affiliate: nil,
        vertical: nil,
        module_code: nil,
        access_key: nil
      }
    end
    let(:expected_error_msg) do
      "[\"Query can't be blank\",\"Position can't be blank\","\
      "\"Module code can't be blank\",\"Url can't be blank\","\
      "\"Affiliate can't be blank\",\"Access key can't be blank\"]"
    end

    it_behaves_like 'an unsuccessful click request'
  end

  it_behaves_like 'does not accept GET requests'
  it_behaves_like 'urls with invalid utf-8'
end
