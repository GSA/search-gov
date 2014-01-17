class MigrateElasticsearchIndexesToAliases < ActiveRecord::Migration
  def up
    ElasticFeaturedCollection.create_index unless ElasticFeaturedCollection.index_exists?
    ElasticBoostedContent.create_index unless ElasticBoostedContent.index_exists?
  end

  def down
  end
end
