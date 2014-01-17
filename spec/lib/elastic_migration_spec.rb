require 'spec_helper'

describe ElasticMigration do
  describe '.migrate' do
    it "should move reader and writer alias to a new timestamped index" do
      old_index = ES::client.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      ElasticMigration.migrate("IndexedDocument")
      new_index = ES::client.indices.get_alias(name: ElasticIndexedDocument.reader_alias).keys.first
      new_index.should > old_index
      new_index = ES::client.indices.get_alias(name: ElasticIndexedDocument.writer_alias).keys.first
      new_index.should > old_index
    end
  end
end