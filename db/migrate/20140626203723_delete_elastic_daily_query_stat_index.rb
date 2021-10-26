class DeleteElasticDailyQueryStatIndex < ActiveRecord::Migration
  def up
    Es::client_writers.each { |client| client.indices.delete(index: "#{Rails.env}-usasearch-elastic_daily_query_stats-*") }
  end

  def down
  end
end
