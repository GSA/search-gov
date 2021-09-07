# frozen_string_literal: true

describe I14yCollections do
  describe '.cached_connection' do
    subject(:cached_connection) { described_class.cached_connection }

    it 'returns a cached connection' do
      expect(cached_connection).to be_an_instance_of(CachedSearchApiConnection)
    end
  end

  describe '.search' do
    subject(:search) { described_class.search(params) }

    let(:params) do
      { handles: 'testing' }
    end

    before do
      stub_request(:get, /#{I14yCollections::API_ENDPOINT}/)
    end

    it 'uses a cached connection' do
      expect_any_instance_of(CachedSearchApiConnection).to receive(:get).
        and_call_original
      search
    end
  end
end
