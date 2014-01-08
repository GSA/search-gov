require 'spec_helper'

describe ElasticResqueMigration do
  describe '.migrate' do
    it "should use Resque to move reader and writer alias to a new timestamped index" do
      ElasticIndexedDocument.should_receive(:migrate_writer)
      ElasticResqueIndexer.should_receive(:index_all).with("IndexedDocument")
      Resque.should_receive(:enqueue).with(ElasticMigrateReader, "IndexedDocument")
      ElasticResqueMigration.migrate("IndexedDocument")
    end
  end
end