require 'spec_helper'

describe SearchImpression, ".log" do
  context 'params contains key with period' do
    let(:params) { { "foo" => "yep", "bar.blat" => "nope" } }
    let(:search) { double(Search, modules: %w(BWEB), diagnostics: { AWEB: { snap: 'judgement' } }) }
    let(:request) { double("request", remote_ip: '1.2.3.4', url: 'http://www.gov.gov/', referer: 'http://www.gov.gov/ref', user_agent: 'whatevs', headers: {}) }

    it 'omits that parameter' do
      time = Time.now
      allow(Time).to receive(:now).and_return time
      expect(Rails.logger).to receive(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://www.gov.gov/\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"diagnostics\":[{\"snap\":\"judgement\",\"module\":\"AWEB\"}],\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      SearchImpression.log(search, "web", params, request)
    end
  end

  context 'headers contains X-Original-Request header' do
    let(:params) { { "foo" => "yep", "bar.blat" => "nope" } }
    let(:search) { double(Search, modules: %w(BWEB), diagnostics: { AWEB: { snap: 'judgement' } }) }
    let(:request) { double("request", remote_ip: '1.2.3.4', url: 'http://www.gov.gov/', referer: 'http://www.gov.gov/ref', user_agent: 'whatevs', headers: { 'X-Original-Request' => 'http://test.gov' }) }

    it 'should log a non-null value for original_request' do
      time = Time.now
      allow(Time).to receive(:now).and_return time
      expect(Rails.logger).to receive(:info).with("[X-Original-Request] (\"http://test.gov\")")
      expect(Rails.logger).to receive(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://test.gov\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"diagnostics\":[{\"snap\":\"judgement\",\"module\":\"AWEB\"}],\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      SearchImpression.log(search, "web", params, request)
    end
  end
end
