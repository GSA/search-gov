require 'spec_helper'

describe 'Clicked' do
  let(:escaped_url) { 'https://search.gov/%28 %3A%7C%29' }
  let(:unescaped_url) { 'https://search.gov/(+:|)' }
  let(:params) do
    {
      u: escaped_url,
      q: 'test_query',
      p: '1',
      a: 'test_affiliate',
      v: 'test_vertical',
      s: 'test_source'
    }
  end

  context 'when correct information is passed in' do
    it 'returns success with a blank message body' do
      post '/clicked', params: params
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'sends the expected params to Click.log' do
      expect(Click).to receive(:log).with(
        unescaped_url,
        'test_query',
        '127.0.0.1',
        'test_affiliate',
        '1',
        'test_source',
        'test_vertical',
        nil
      )

      post '/clicked', params: params
    end
  end

  context 'when required params are missing' do
    before { post '/clicked', params: params.without(missing_param) }

    context 'missing url' do
      let(:missing_param) { :u }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["url must be present"]}')
      end

      it 'does not log the click information' do
        expect(Click).not_to receive(:log)
      end
    end

    context 'missing query' do
      let(:missing_param) { :q }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["query must be present"]}')
      end

      it 'does not log the click information' do
        expect(Click).not_to receive(:log)
      end
    end

    context 'missing position' do
      let(:missing_param) { :p }

      it 'returns a 400 and an error message' do
        expect(response.status).to eq 400
        expect(response.body).to eq('{"errors":["position must be present"]}')
      end

      it 'does not log the click information' do
        expect(Click).not_to receive(:log)
      end
    end

    context 'missing source' do
      let(:missing_param) { :s }

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
      post '/clicked', params: params.without(:u, :q)

      expect(response.status).to eq 400
      expected_long_error = '{"errors":["url must be present","query must be present"]}'
      expect(response.body).to eq(expected_long_error)
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
