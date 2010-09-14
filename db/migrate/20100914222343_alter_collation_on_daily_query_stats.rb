class AlterCollationOnDailyQueryStats < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `daily_query_stats` CHANGE `query` `query` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL"  
  end

  def self.down
  end
end
