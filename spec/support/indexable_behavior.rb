# frozen_string_literal: true

shared_examples 'an indexable' do
  describe '.search_for' do
    subject(:search_for) { described_class.search_for(options) }

    let(:options) do
      { q: 'search term' }
    end

    before { allow(Rails.logger).to receive(:info) }

    context 'when searching raises an exception' do
      it 'returns an appropriate result set with zero hits' do
        expect(Es::CustomIndices.client_reader).to receive(:search).and_raise StandardError
        expect(described_class.search_for(options)).to be_a(ElasticResults)
      end
    end

    it 'logs the query JSON' do
      search_for
      expect(Rails.logger).to have_received(:info).with(/"query":"search term"/)
    end

    context 'when the query includes sensitive data' do
      let(:options) do
        { q: '123-45-6789' }
      end

      it 'redacts the data' do
        search_for
        expect(Rails.logger).not_to have_received(:info).with(/123-45-6789/)
      end
    end
  end

  context 'when there are multiple clusters' do
    let(:es1) { Elasticsearch::Client.new(host: 'localhost:9200') }
    # Fake a second cluster by using a second connection
    let(:es2) { Elasticsearch::Client.new(host: 'localhost:9200') }

    before do
      allow(Es::CustomIndices).to receive(:client_writers).and_return [es1, es2]
    end

    describe '.index_exists?' do
      context 'when index does not exist' do
        before do
          described_class.delete_index
        end

        it 'returns false' do
          expect(described_class.index_exists?).to be false
        end
      end
    end

    describe '.delete_index' do
      it 'sends a delete to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          expect(client).to receive(:indices).and_return es_indices
          expect(es_indices).to receive(:delete)
        end
        described_class.delete_index
      end
    end

    describe '.create_index' do
      it 'sends a create to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          allow(client).to receive(:indices).and_return es_indices
          expect(es_indices).to receive(:create)
          expect(es_indices).to receive(:put_alias).with(index: described_class.index_name, name: described_class.writer_alias)
          expect(es_indices).to receive(:put_alias).with(index: described_class.index_name, name: described_class.reader_alias)
        end
        described_class.create_index
      end
    end

    describe '.migrate_writer' do
      before do
        allow(described_class).to receive(:update_alias)
      end

      it 'sends a create to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          allow(client).to receive(:indices).and_return es_indices
          expect(es_indices).to receive(:create)
        end
        described_class.migrate_writer
      end
    end

    describe '.commit' do
      it 'sends a refresh to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          allow(client).to receive(:indices).and_return es_indices
          expect(es_indices).to receive(:refresh).with(index: described_class.writer_alias)
        end
        described_class.commit
      end
    end

    describe '.bulk' do
      it 'sends a bulk request to each cluster' do
        body = 'body'
        [es1, es2].each do |client|
          expect(described_class).to receive(:client_bulk).with(client, body)
        end
        described_class.bulk(body)
      end
    end

    describe '.optimize' do
      it 'sends an optimize to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          allow(client).to receive(:indices).and_return es_indices
          expect(es_indices).to receive(:optimize)
        end
        described_class.optimize
      end
    end

    describe '.delete_by_query' do
      it 'sends a delete by query request to each cluster' do
        [es1, es2].each do |client|
          expect(client).to receive(:delete_by_query).with(index: described_class.writer_alias, q: 'foo:1 bar:two', default_operator: 'AND')
        end
        described_class.delete_by_query({ foo: 1, bar: 'two' })
      end
    end
  end

  describe 'bulk request errors' do
    context 'when there are API errors on the bulk request' do
      before do
        response = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/elasticsearch_bulk_error.json"))
        @client = double('ElasticSearch')
        allow(@client).to receive(:bulk).and_return response
        allow(@client).to receive_message_chain(:transport, :hosts).and_return [{ host: 'localhost' }]
      end

      it 'logs them' do
        expect(Rails.logger).to receive(:error)
        described_class.send(:client_bulk, @client, 'body')
      end
    end

    context 'when there are transport/network errors on the bulk request' do
      before do
        @client = double('ElasticSearch')
        allow(@client).to receive(:bulk).and_raise
        allow(@client).to receive_message_chain(:transport, :hosts).and_return [{ host: 'localhost' }]
      end

      it 'logs them' do
        expect(Rails.logger).to receive(:error)
        described_class.send(:client_bulk, @client, 'body')
      end
    end
  end
end
