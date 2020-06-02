require 'spec_helper'

describe '/api/v2/click' do
  let(:escaped_url) { 'https://search.gov/%28 %3A%7C%29' }
  let(:unescaped_url) { 'https://search.gov/(+:|)' }
  let(:params) do
    {
      url: escaped_url,
      query: 'test_query',
      client_ip: '127.0.0.1',
      position: '1',
      affiliate: 'nps.gov',
      vertical: 'test_vertical',
      module_code: 'test_source',
      user_agent: 'test_user_agent',
      access_key: 'basic_key'
    }
  end
  let(:click_mock) { instance_double(ClickApi, valid?: true, log: nil) }

  context 'with the required params' do
    it 'returns success with a blank message body' do
      post '/api/v2/click', params: params

      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'sends the expected params to Click' do
      expect(ClickApi).to receive(:new).with(
        access_key: 'basic_key',
        affiliate: 'nps.gov',
        client_ip: '127.0.0.1',
        module_code: 'test_source',
        position: '1',
        query: 'test_query',
        url: 'https://search.gov/(+:|)',
        user_agent: 'test_user_agent',
        vertical: 'test_vertical'
      ).and_return click_mock

      post '/api/v2/click', params: params
    end

    it 'logs a click' do
      allow(ClickApi).to receive(:new).and_return click_mock

      post '/api/v2/click', params: params

      expect(click_mock).to have_received(:log)
    end
  end

  context 'invalid access_key' do
    it 'returns an error message' do
      params['access_key'] = 'invalid'
      post '/api/v2/click', params: params

      expect(response.status).to eq 401
      expect(response.body).to eq('["Access key is invalid"]')
    end
  end

  context 'when required params are missing' do
    error_msg = ["Url can't be blank", "Query can't be blank",
                 "Position can't be blank", "Module code can't be blank",
                 "Affiliate can't be blank", "Access key can't be blank"]

    it 'has the expected error message' do
      post '/api/v2/click', params: params.without(:affiliate, :access_key, :url,
                                                   :query, :position, :module_code)

      expect(response.status).to eq 400
      errors_with_spaces_removed = error_msg.to_s.gsub(', ', ',')
      expect(response.body).to eq(errors_with_spaces_removed)
    end

    it 'does not log a click' do
      allow(ClickApi).to receive(:new).and_return click_mock
      allow(click_mock).to receive(:valid?).and_return false
      allow(click_mock).to receive_message_chain(:errors, :full_messages).
        and_return(error_msg)

      post '/api/v2/click', params: params.without(:affiliate, :access_key, :url,
                                                   :query, :position, :module_code)

      expect(click_mock).not_to have_received(:log)
    end
  end

  context 'a GET request' do
    it 'returns an error' do
      get '/api/v2/click', params: params
      expect(response.success?).to be(false)
      expect(response.status).to eq 302
    end
  end
end
