class MigrateBlendedIndexes < ActiveRecord::Migration
  def up
    ElasticResqueMigration.migrate("NewsItem") if ElasticNewsItem.index_exists?
    ElasticResqueMigration.migrate("IndexedDocument") if ElasticIndexedDocument.index_exists?
  end

  def down
  end
end
