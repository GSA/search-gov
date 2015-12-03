require 'spec_helper'

describe SearchImpression, ".log" do
  context 'params contains key with period' do
    let(:params) { { "foo" => "yep", "bar.blat" => "nope" } }
    let(:search) { mock(Search, modules: %w(BWEB)) }
    let(:request) { mock("request", remote_ip: '1.2.3.4', url: 'http://www.gov.gov/', referer: 'http://www.gov.gov/ref', user_agent: 'whatevs') }

    it 'omits that parameter' do
      time = Time.now
      Time.stub(:now).and_return time
      Rails.logger.should_receive(:info).with("[Search Impression] {\"clientip\":\"1.2.3.4\",\"request\":\"http://www.gov.gov/\",\"referrer\":\"http://www.gov.gov/ref\",\"user_agent\":\"whatevs\",\"time\":\"#{time.to_formatted_s(:db)}\",\"vertical\":\"web\",\"modules\":\"BWEB\",\"params\":{\"foo\":\"yep\"}}")
      SearchImpression.log(search, "web", params, request)
    end
  end
end
