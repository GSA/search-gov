class CreateElasticBoostedContent < ActiveRecord::Migration
  def up
    ElasticBoostedContent.create_index unless ElasticBoostedContent.index_exists?
  end

  def down
    ElasticBoostedContent.delete_index if ElasticBoostedContent.index_exists?
  end
end
