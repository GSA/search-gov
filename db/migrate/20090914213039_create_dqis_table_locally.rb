class CreateDqisTableLocally < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE IF NOT EXISTS `daily_query_ip_stats` ( `id` int(11) NOT NULL auto_increment, `day` date NOT NULL, `query` varchar(100) NOT NULL default '', `ipaddr` varchar(17) NOT NULL default '', `times` int(11) NOT NULL, PRIMARY KEY  (`id`), KEY `index_daily_query_ip_stats_on_query` (`query`) ) ENGINE=InnoDB  DEFAULT CHARSET=utf8"
  end

  def self.down
    # This is just to build the queries table locally on the development/test environments. We don't want to accidentally nuke the production table
    raise IrreversibleMigration
  end
end
