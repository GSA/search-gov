require 'spec_helper'

describe '/api/v2/click' do
  let(:escaped_url) { 'https://search.gov/%28 %3A%7C%29' }
  let(:unescaped_url) { 'https://search.gov/(+:|)' }
  let(:params) do
    {
      clicked_url: escaped_url,
      query: 'test_query',
      click_ip: '127.0.0.1',
      position: '1',
      affiliate: 'nps.gov',
      vertical: 'test_vertical',
      source: 'test_source',
      user_agent: 'test_user_agent',
      access_key: 'basic_key'
    }
  end

  context 'with the required params' do
    it 'returns success with a blank message body' do
      post '/api/v2/click', params: params
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end


    it 'sends the expected params to Click.log' do
      expect(Click).to receive(:log).with(
        unescaped_url,
        'test_query',
        '127.0.0.1',
        'nps.gov',
        '1',
        'test_source',
        'test_vertical',
        'test_user_agent',
        'basic_key'
      )

      post '/api/v2/click', params: params
    end
  end

  context 'invalid access_key' do
    it 'returns an error message' do
      params['access_key'] = 'blahblah'
      post '/api/v2/click', params: params

      expect(response.status).to eq 401
      expect(response.body).to eq('{"errors":["access_key is invalid"]}')
    end
  end

  context 'when required params are missing' do
    before { post '/api/v2/click', params: params.without(missing_param) }

    context 'missing access_key' do
      let(:missing_param) { :access_key }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["access_key must be present"]}')
      end
    end

    context 'missing url' do
      let(:missing_param) { :clicked_url }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["clicked_url must be present"]}')
      end
    end

    context 'missing query' do
      let(:missing_param) { :query }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["query must be present"]}')
      end
    end

    context 'missing position' do
      let(:missing_param) { :position }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["position must be present"]}')
      end
    end

    context 'missing source' do
      let(:missing_param) { :source }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["source must be present"]}')
      end

      it 'does not log the click information' do
        expect(Click).not_to receive(:log)
      end
    end
  end

  context 'missing multiple params' do
    it 'has the expected error message' do
      post '/api/v2/click', params: params.without(:clicked_url, :query)

      expect(response.status).to eq 400
      expected_long_error = '{"errors":["clicked_url must be present","query must be present"]}'
      expect(response.body).to eq(expected_long_error)
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
