require 'spec_helper'

describe StatusesController do
  describe '#outbound_rate_limit' do
    let(:rate_limit_status) do
      mock(OutboundRateLimitStatus,
           to_s: 'expected_text')
    end

    before do
      OutboundRateLimitStatus.should_receive(:find_by_name).
        with('google_api').
        and_return(rate_limit_status)
      get :outbound_rate_limit, name: 'google_api', format: 'text'
    end

    it { should respond_with :success }

    it 'returns JSON' do
      expect(response.body).to eq('expected_text')
    end
  end
end
