class CreateElasticNewsItemIndex < ActiveRecord::Migration
  def up
    ElasticNewsItem.create_index unless ElasticNewsItem.index_exists?
  end

  def down
    ElasticNewsItem.delete_index if ElasticNewsItem.index_exists?
  end
end
