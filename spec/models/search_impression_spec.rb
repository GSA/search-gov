# frozen_string_literal: true

require 'spec_helper'

describe 'SearchImpression' do
  describe '.log' do
    let!(:request) { double('request', remote_ip: '1.2.3.4', url: 'http://www.gov.gov/', referer: 'http://www.gov.gov/ref', user_agent: 'whatevs', headers: {}) }
    let!(:search) { double(Search, modules: ['BWEB'], diagnostics: { AWEB: { snap: 'judgement' } }) }
    let!(:params) { { 'foo' => 'yep' } }
    let(:time) { Time.now }

    before do
      allow(Time).to receive(:now).and_return(time)
      allow(Rails.logger).to receive(:info)

      SearchImpression.log(search, 'web', params, request)
    end

    context 'with regular params' do
      it 'has the expected log line' do
        expect(Rails.logger).to have_received(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://www.gov.gov/\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"diagnostics\":[{\"snap\":\"judgement\",\"module\":\"AWEB\"}],\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      end
    end

    context "with routed query module and empty diagnostics" do
      let!(:search) { double(Search, modules: ['QRTD'], diagnostics: {}) }

      it 'has the expected log line parts' do
        expect(Rails.logger).to have_received(:info).with(include('[Search Impression]'))
        expect(Rails.logger).to have_received(:info).with(include('"modules":"QRTD"'))
        expect(Rails.logger).to have_received(:info).with(include('"diagnostics":[]'))
      end
    end

    context 'params contains key with period' do
      let(:params) { { 'foo' => 'yep', 'bar.blat' => 'nope' } }

      it 'omits that parameter' do
        expect(Rails.logger).to have_received(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://www.gov.gov/\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"diagnostics\":[{\"snap\":\"judgement\",\"module\":\"AWEB\"}],\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      end
    end

    context 'headers contains X-Original-Request header' do
      let!(:request) { double('request', remote_ip: '1.2.3.4', url: 'http://www.gov.gov/', referer: 'http://www.gov.gov/ref', user_agent: 'whatevs', headers: { 'X-Original-Request' => 'http://test.gov' }) }

      it 'should log a non-null value for original_request' do
        expect(Rails.logger).to have_received(:info).with('[X-Original-Request] ("http://test.gov")')
        expect(Rails.logger).to have_received(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://test.gov\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"diagnostics\":[{\"snap\":\"judgement\",\"module\":\"AWEB\"}],\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      end
    end
  end
end
