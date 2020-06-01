require 'spec_helper'

describe 'Clicked' do
  let(:escaped_url) { 'https://search.gov/%28 %3A%7C%29' }
  let(:unescaped_url) { 'https://search.gov/(+:|)' }
  let(:params) do
    {
      url: escaped_url,
      query: 'test_query',
      position: '1',
      affiliate: 'test_affiliate',
      vertical: 'test_vertical',
      module_code: 'test_source'
    }
  end
  let(:click_mock) { instance_double(Click) }

  context 'when correct information is passed in' do
    it 'returns success with a blank message body' do
      post '/clicked', params: params
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'sends the expected params to click.log' do
      expect(Click).to receive(:new).with(
        url: unescaped_url,
        query: 'test_query',
        client_ip: '127.0.0.1',
        affiliate: 'test_affiliate',
        position: '1',
        module_code: 'test_source',
        vertical: 'test_vertical',
        user_agent: nil
      ).and_return(click_mock)
      allow(click_mock).to receive(:valid?).and_return true
      expect(click_mock).to receive(:log)

      post '/clicked', params: params
    end
  end

  context 'when required params are missing' do
    it 'has the expected error message' do
      post '/clicked', params: params.without(:url, :query, :position, :module_code)

      expect(response.status).to eq 400
      error_msg = "[\"Url can't be blank\",\"Query can't be blank\","\
                  "\"Position can't be blank\",\"Module code can't be blank\"]"
      expect(response.body).to eq(error_msg)
    end

    it 'does not log a click' do
      expect(Click).to receive(:new).and_return click_mock
      allow(click_mock).to receive(:valid?).and_return false
      allow(click_mock).to receive_message_chain(:errors, :full_messages)
      expect(click_mock).not_to receive(:log)

      post '/clicked', params: params.without(:url, :query, :position, :module_code)
    end
  end

  context 'a GET request' do
    it 'returns an error' do
      get '/clicked', params: params
      expect(response.success?).to be(false)
      expect(response.status).to eq 302
    end
  end
end
