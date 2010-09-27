class AddQueryDayAffiliateLocaleIndexToDqs < ActiveRecord::Migration
  def self.up
    add_index :daily_query_stats, [:query, :day, :affiliate, :locale], :name => 'qdal', :unique => true
  end

  def self.down
    remove_index :daily_query_stats, :name => 'qdal'
  end
end
