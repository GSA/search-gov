require 'spec_helper'

describe ElasticResqueMigration do
  describe '.migrate' do
    it 'should use Resque to move reader and writer alias to a new timestamped index' do
      expect(ElasticIndexedDocument).to receive(:migrate_writer)
      expect(ElasticResqueIndexer).to receive(:index_all).with('IndexedDocument')
      expect(Resque).to receive(:enqueue).with(ElasticMigrateReader, 'IndexedDocument')
      ElasticResqueMigration.migrate('IndexedDocument')
    end
  end
end