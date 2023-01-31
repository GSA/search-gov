require 'spec_helper'

describe CaptchaMetrics do
  subject { described_class.new(request) }

  let(:statsd) { double(Datadog::Statsd, increment: nil) }
  let(:headers) { { 'HTTP_X_BON_REASON' => reason_header } }
  let(:request) { double(:request, headers: headers) }
  let(:reason_header) { :stale_cookie }

  before do
    allow(Datadog::Statsd).to receive(:new).and_return(statsd)
  end

  describe '.new' do
    let(:request) { :request }

    it 'sets the request attribute' do
      captcha_metrics = described_class.new(request)
      expect(captcha_metrics.request).to eq(request)
    end
  end

  describe '#increment_counter_for' do
    subject(:increment_counter) { described_class.new(request).increment_counter_for(activity) }

    let(:activity) { :activity }

    it "increments the provided activity's counter" do
      expect(statsd).to receive(:increment).with(activity, tags: ['REASON:stale_cookie'] )
      increment_counter
    end

    context 'when the request has additional X-BON headers' do
      let(:headers) { {
        'HTTP_X_BON_REASON' => reason_header,
        'HTTP_X_BON_FOO' => 'bar',
        'HTTP_X_BON_BAZ' => 'quux',
        'HTTP_X_NOT_A_BON_HEADER' => 'rutabaga'
      } }

      it 'includes each X-BON header as a tag when incrementing the activity counter' do
        expect(statsd).to receive(:increment).with(:activity, tags: ['BAZ:quux', 'FOO:bar', 'REASON:stale_cookie'] )
        increment_counter
      end
    end
  end
end
