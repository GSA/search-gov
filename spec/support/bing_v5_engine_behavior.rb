shared_examples 'a Bing V5 engine' do
  it_behaves_like 'a Bing engine'

  describe '#params' do
    subject { described_class.new({ }) }

    it 'uses "Moderate" for safeSearch' do
      expect(subject.params[:safeSearch]).to eq('Moderate')
    end
  end

  describe '#execute_query' do
    subject { described_class.new(options) }
    let(:bing_response_body) { '{}' }

    before do
      stub_request(:get, %r{/bing/v5.0/}).to_return({ body: bing_response_body })
    end

    describe 'authenticating' do
      context 'when no password is provided in the options' do
        let(:options) { { offset: 0, limit: 20 } }

        it 'uses the hosted-search password as the "Ocp-Apim-Subscription-Key" header value' do
          subject.execute_query
          expect(subject.api_connection.connection.headers['Ocp-Apim-Subscription-Key']).to eq(described_class::DEFAULT_HOSTED_PASSWORD)
        end
      end

      context 'when an password is provided in the options' do
        let(:options) { { offset: 0, limit: 20, password: 'b1rd1sth3p4ssw0rd' } }

        it 'uses that password as the "Ocp-Apim-Subscription-Key" header value' do
          subject.execute_query
          expect(subject.api_connection.connection.headers['Ocp-Apim-Subscription-Key']).to eq('b1rd1sth3p4ssw0rd')
        end
      end
    end

    describe 'errors returned from bing' do
      let(:options) { { offset: 0, limit: 20, password: 'b1rd1sth3p4ssw0rd' } }
      let(:bing_response_body) { '{"status_code":401,"message":"bad key"}' }

      it 'raises an exception' do
        expect { subject.execute_query }.to raise_error('received status code 401 - bad key')
      end
    end
  end

  describe 'connection caching' do
    let(:bing_v5_engine_unlimited_connection) { BingV5Engine.unlimited_api_connection }
    let(:bing_v5_engine_rate_limited_connection) { BingV5Engine.rate_limited_api_connection }

    context 'when using unlimited API connections' do
      let(:connection_a) { described_class.unlimited_api_connection }
      let(:connection_b) { described_class.unlimited_api_connection }

      it 'should reuse the same connection' do
        expect(connection_a).to eq(connection_b)
      end

      it 'should not reuse the connection created by BingV5Engine' do
        expect(connection_a.class).to eq(bing_v5_engine_unlimited_connection.class)
        expect(connection_a).not_to eq(bing_v5_engine_unlimited_connection)
      end
    end

    context 'when using rate-limited API connections' do
      let(:connection_a) { described_class.rate_limited_api_connection }
      let(:connection_b) { described_class.rate_limited_api_connection }

      it 'should be the same connection' do
        expect(connection_a).to eq(connection_b)
      end

      it 'should not reuse the connection created by BingV5Engine' do
        expect(connection_a.class).to eq(bing_v5_engine_rate_limited_connection.class)
        expect(connection_a).not_to eq(bing_v5_engine_rate_limited_connection)
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

  describe 'api cache namespacing' do
    it 'uses the BingV5Engine namespace' do
      expect(described_class.api_cache_namespace).to eq(BingV5Engine::API_CACHE_NAMESPACE)
    end

    it 'has a different namespace than AzureEngine' do
      expect(described_class.api_cache_namespace).not_to eq(AzureEngine::NAMESPACE)
    end
  end
end
