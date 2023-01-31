require 'spec_helper'

describe OutboundRateLimitStatus do
  subject(:status) { described_class.new(outbound_rate_limit) }

  let(:outbound_rate_limit) do
    mock_model(OutboundRateLimit,
               limit: 1000,
               name: 'my_api')
  end

  let(:rate_limiter) { double(ApiRateLimiter) }

  before do
    expect(ApiRateLimiter).to receive(:new).with('my_api').and_return(rate_limiter)
    expect(rate_limiter).to receive(:get_or_initialize_used_count).and_return(17)
  end

  describe '#new' do
    its(:used_percentage) { should eq('2%') }
    its(:used_count) { should eq(17) }
  end

  describe '#to_s' do
    it 'sets used_percentage' do
      expect(status.to_s).to eq('name:my_api;limit:1000;used_count:17;used_percentage:2%')
    end
  end
end
