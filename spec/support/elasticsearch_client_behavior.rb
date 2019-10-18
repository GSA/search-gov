shared_examples 'an Elasticsearch client' do
  describe 'configuration' do
    it 'uses an adapter that supports persistent connections' do
      handler = client.transport.connections.first.connection.builder.handlers.first
      expect(handler).to eq(Faraday::Adapter::Typhoeus)
    end

    it 'uses the specified options' do
      options = {
        log: false,
        randomize_hosts: true,
        reload_connections: true,
        reload_on_failure: true,
        retry_on_failure: 1
      }
      expect(client.transport.options).to include(options)
    end

    it 'can connect to Elasticsearch' do
      expect(client.ping).to eq(true)
    end
  end
end
