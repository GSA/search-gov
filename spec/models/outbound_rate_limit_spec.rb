require 'spec_helper'

describe OutboundRateLimit do
  it { is_expected.to validate_presence_of :limit }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_inclusion_of(:interval).in_array(%w(day month)) }

  describe '#current_interval' do
    subject(:outbound_rate_limit) { described_class.new(name: 'rate_limited_api', limit: 1000, interval: interval).current_interval }
    context 'when the interval is "day"' do
      let(:interval) { 'day' }

      specify { expect(subject).to eq(Date.current.strftime('%Y-%m-%d')) }
    end

    context 'when the interval is "month"' do
      let(:interval) { 'month' }

      specify { expect(subject).to eq(Date.current.strftime('%Y-%m')) }
    end

    context 'when the interval is invalid' do
      let(:interval) { 'fortnight' }

      specify { expect { subject }.to raise_error }
    end
  end

  describe '#ttl' do
    subject(:outbound_rate_limit) { described_class.new(name: 'rate_limited_api', limit: 1000, interval: interval).ttl }

    context 'when the interval is "day"' do
      let(:interval) { 'day' }

      specify { expect(subject).to eq(8.days.to_i) }
    end

    context 'when the interval is "month"' do
      let(:interval) { 'month' }

      specify { expect(subject).to eq(13.months.to_i) }
    end

    context 'when the interval is invalid' do
      let(:interval) { 'fortnight' }

      specify { expect { subject }.to raise_error }
    end
  end
end
