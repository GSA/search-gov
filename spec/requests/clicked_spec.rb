require 'spec_helper'

describe 'Clicked' do
  before do
    @url = 'http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++%29++%28site%3Awww.uspto.gov+%7C+site%3Aeipweb.uspto.gov%29+'
    @unescaped_url = CGI::unescape(@url).gsub(' ', '+')
    @query = 'chicken & beef recall'
    @timestamp = '1271978905'
    @affiliate_name = 'some affiliate'
    @position = '7'
    @module = 'RECALL'
    @vertical = 'web'
    @locale = 'en'
    @model_id = '1234'
  end

  context 'when correct information is passed in' do

    it 'returns success with a blank message body' do
      get '/clicked', params: { u: @url,
                                q: @query,
                                t: @timestamp,
                                a: @affiliate_name,
                                p: @position,
                                s: @module,
                                v: @vertical,
                                l: @locale,
                                i: @model_id }
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'logs the click' do
      expect(Click).to receive(:log).with(@unescaped_url,
                                          @query,
                                          '2010-04-22 23:28:25',
                                          '127.0.0.1',
                                          @affiliate_name,
                                          @position,
                                          @module,
                                          @vertical,
                                          @locale,
                                          anything(),
                                          @model_id)
      get '/clicked', params: { u: @url,
                                q: @query,
                                t: @timestamp,
                                a: @affiliate_name,
                                p: @position,
                                s: @module,
                                v: @vertical,
                                l: @locale,
                                i: @model_id }
    end

  end

  context 'when click url is missing' do
    before do
      get '/clicked', params: { q: @query,
                                t: @timestamp,
                                a: @affiliate_name,
                                p: @position,
                                s: @module,
                                v: @vertical,
                                l: @locale,
                                i: @model_id }
    end

    it 'returns success with a blank message body' do
      expect(response.success?).to be(true)
      expect(response.body).to eq('')
    end

    it 'does not log the click information' do
      expect(Click).not_to receive(:log)
    end
  end

end
