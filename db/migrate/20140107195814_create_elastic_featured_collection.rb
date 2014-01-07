class CreateElasticFeaturedCollection < ActiveRecord::Migration
  def up
    ElasticFeaturedCollection.create_index unless ElasticFeaturedCollection.index_exists?
  end

  def down
    ElasticFeaturedCollection.delete_index if ElasticFeaturedCollection.index_exists?
  end
end
