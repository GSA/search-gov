require 'spec_helper'

describe ElasticMigration do
  describe '.migrate' do
    it 'should move reader and writer alias to a new timestamped index' do
      old_index = Es::CustomIndices.client_reader.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      described_class.migrate('IndexedDocument')
      new_index = Es::CustomIndices.client_writers.first.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      expect(new_index).to be > old_index
      new_index = Es::CustomIndices.client_writers.first.indices.get_alias(name: ElasticIndexedDocument.writer_alias).keys.first
      expect(new_index).to be > old_index
    end
  end
end
