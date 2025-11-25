# frozen_string_literal: true

shared_examples 'an Elasticsearch client' do |context_type: nil|
  describe 'configuration' do
    it 'uses an adapter that supports persistent connections' do
      handler = client.transport.connections.first.connection.builder.handlers.first
      expect(handler).to eq(Faraday::Adapter::Typhoeus)
    end

    it 'uses the specified options' do
      options = {
        log: true,
        randomize_hosts: true,
        reload_connections: false,
        reload_on_failure: false,
        retry_on_failure: 1
      }
      expect(client.transport.options).to include(options)
    end

    it 'can connect to Elasticsearch' do
      expect(client.ping).to be true
    end
  end

  describe 'client logger' do
    let(:logger) { client.transport.logger }
    let(:expected_port) { OpenSearchConfig.enabled? ? '9300' : '9200' }
    let(:expected_tag) do
      if OpenSearchConfig.enabled?
        context_type == :analytics ? 'OPENSEARCH_ANALYTICS' : 'OPENSEARCH'
      else
        'ES'
      end
    end

    before do
      allow(logger).to receive(:info)
    end

    it 'logs the Elasticsearch request' do
      client.count
      expect(logger).to have_received(:info).with(%r{localhost:#{expected_port}/_count})
    end

    it 'colorizes and tags the logs with ES, the timestamp, and the severity' do
      expect(logger.formatter.call('DEBUG', Time.utc(2022, 5, 26), 'progname', 'message')).
        to eq("\e[2m[#{expected_tag}][2022-05-26T00:00:00.0000Z][DEBUG] message\n\e[0m")
    end

    context 'when the request returns a warning' do
      before do
        stub_request(:get, /_count/).
          to_return(status: 200, headers: { warning: 'danger' })
      end

      it 'logs with the correct formatting' do
        allow(logger).to receive(:warn)
        client.count
        expect(logger).to have_received(:warn).with(/danger/)
      end
    end
  end
end
