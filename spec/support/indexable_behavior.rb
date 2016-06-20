shared_examples "an indexable" do

  context "when searching raises an exception" do
    it "should return an appropriate result set with zero hits" do
      ES::client_reader.should_receive(:search).and_raise StandardError
      options = { q: 'query', affiliate_id: affiliate.id, language: affiliate.indexing_locale }
      described_class.search_for(options).should be_a_kind_of(ElasticResults)
    end
  end

  context 'when there are multiple clusters' do
    let(:es1) { Elasticsearch::Client.new(host: 'localhost') }
    let(:es2) { Elasticsearch::Client.new(host: '127.0.0.1') }

    before do
      ES.stub(:client_writers).and_return [es1, es2]
    end

    describe ".index_exists?" do
      context 'when index does not exist' do
        before do
          described_class.delete_index
        end

        it 'should return false' do
          described_class.index_exists?.should be_false
        end
      end
    end

    describe ".delete_index" do
      it 'should send a delete to each cluster' do
        [es1, es2].each do |client|
          es_indices=client.indices
          client.should_receive(:indices).and_return es_indices
          es_indices.should_receive(:delete)
        end
        described_class.delete_index
      end
    end

    describe ".create_index" do
      it 'should send a create to each cluster' do
        [es1, es2].each do |client|
          es_indices=client.indices
          client.stub(:indices).and_return es_indices
          es_indices.should_receive(:create)
          es_indices.should_receive(:put_alias).with(index: described_class.index_name, name: described_class.writer_alias)
          es_indices.should_receive(:put_alias).with(index: described_class.index_name, name: described_class.reader_alias)
        end
        described_class.create_index
      end
    end

    describe ".migrate_writer" do
      before do
        described_class.stub(:update_alias)
      end

      it 'should send a create to each cluster' do
        [es1, es2].each do |client|
          es_indices=client.indices
          client.stub(:indices).and_return es_indices
          es_indices.should_receive(:create)
        end
        described_class.migrate_writer
      end
    end

    describe ".commit" do
      it 'should send a refresh to each cluster' do
        [es1, es2].each do |client|
          es_indices=client.indices
          client.stub(:indices).and_return es_indices
          es_indices.should_receive(:refresh).with(index: described_class.writer_alias)
        end
        described_class.commit
      end
    end

    describe ".bulk" do
      it 'should send a bulk request to each cluster' do
        body = "body"
        [es1, es2].each do |client|
          described_class.should_receive(:client_bulk).with(client, body)
        end
        described_class.bulk(body)
      end
    end

    describe '.optimize' do
      it 'should send an optimize to each cluster' do
        [es1, es2].each do |client|
          es_indices = client.indices
          client.stub(:indices).and_return es_indices
          es_indices.should_receive(:optimize)
        end
        described_class.optimize
      end
    end

    describe ".delete_by_query" do
      it 'should send a delete by query request to each cluster' do
        [es1, es2].each do |client|
          client.should_receive(:delete_by_query).with(index: described_class.writer_alias, q: 'foo:1 bar:two', default_operator: "AND")
        end
        described_class.delete_by_query({ foo: 1, bar: 'two' })
      end
    end
  end

  describe "bulk request errors" do
    context 'when there are API errors on the bulk request' do
      before do
        response = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/elasticsearch_bulk_error.json"))
        @client = mock('ElasticSearch')
        @client.stub(:bulk).and_return response
        @client.stub_chain(:transport, :hosts).and_return [{ host: 'localhost' }]
      end

      it 'should log them' do
        Rails.logger.should_receive(:error)
        described_class.send(:client_bulk, @client, 'body')
      end
    end

    context 'when there are transport/network errors on the bulk request' do
      before do
        @client = mock('ElasticSearch')
        @client.stub(:bulk).and_raise
        @client.stub_chain(:transport, :hosts).and_return [{ host: 'localhost' }]
      end

      it 'should log them' do
        Rails.logger.should_receive(:error)
        described_class.send(:client_bulk, @client, 'body')
      end
    end
  end

end
