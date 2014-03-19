class CreateDqsIndex < ActiveRecord::Migration
  def up
    ElasticDailyQueryStat.create_index unless ElasticDailyQueryStat.index_exists?
  end

  def down
    ElasticDailyQueryStat.delete_index if ElasticDailyQueryStat.index_exists?
  end
end
