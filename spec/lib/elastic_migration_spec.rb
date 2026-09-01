require 'spec_helper'

describe ElasticMigration do
  describe '.migrate' do
    before do
      skip 'custom Elasticsearch indices are disabled' unless Es.custom_indices_enabled?
      ElasticIndexedDocument.recreate_index
    end

    it 'should move reader and writer alias to a new timestamped index' do
      client = ElasticIndexedDocument.client_reader
      old_index = client.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      described_class.migrate('IndexedDocument')
      new_index = client.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      expect(new_index).to be > old_index
      new_index = client.indices.get_alias(name: ElasticIndexedDocument.writer_alias).keys.first
      expect(new_index).to be > old_index
    end
  end
end
