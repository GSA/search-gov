require 'spec_helper'

describe 'Clicked' do
  let(:escaped_url) { 'https://search.gov/%28 %3A%7C%29' }
  let(:unescaped_url) { 'https://search.gov/(+:|)' }
  let(:params) do
    {
      u: escaped_url,
      q: 'test_query',
      p: '1',
      t: '1588180422',
      a: 'test_affiliate',
      s: 'test_source',
      v: 'test_vertical',
      l: 'test_locale',
      i: 'test_model_id'
    }
  end

  context 'when correct information is passed in' do
    it 'returns success with a blank message body' do
      get '/clicked', params: params
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'sends the expected params to Click.log' do
      expect(Click).to receive(:log).with(
        unescaped_url,
        'test_query',
        '2020-04-29 17:13:42',
        '127.0.0.1',
        'test_affiliate',
        '1',
        'test_source',
        'test_vertical',
        'test_locale',
        nil,
        'test_model_id'
      )

      get '/clicked', params: params
    end
  end

  context 'when click url is missing' do
    before { get '/clicked', params: params.without(:u) }

    it 'returns success with a blank message body' do
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'does not log the click information' do
      expect(Click).not_to receive(:log)
    end
  end
end
