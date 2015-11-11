require 'spec_helper'

describe AzureEngine do
  describe 'connection caching' do
    context 'when using unlimited API connections' do
      let(:connection_a) { described_class.unlimited_api_connection }
      let(:connection_b) { described_class.unlimited_api_connection }

      it 'should be the same connection' do
        expect(connection_a).to eq(connection_b)
      end
    end

    context 'when using rate-limited API connections' do
      let(:connection_a) { described_class.rate_limited_api_connection }
      let(:connection_b) { described_class.rate_limited_api_connection }

      it 'should be the same connection' do
        expect(connection_a).to eq(connection_b)
      end
    end

    context 'when using a mix of unlimited and rate-limited API connections' do
      let(:connection_a) { described_class.unlimited_api_connection }
      let(:connection_b) { described_class.rate_limited_api_connection }

      it 'should be different connections' do
        expect(connection_a).not_to eq(connection_b)
      end
    end
  end
end
