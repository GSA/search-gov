class CreateQueriesTableLocally < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE IF NOT EXISTS `queries` ( `ipaddr` varchar(17) default NULL, `query` varchar(100) default NULL, `affiliate` varchar(32) default NULL, `epoch` int(11) default NULL, `wday` varchar(3) default NULL, `month` varchar(3) default NULL, `day` int(11) default NULL, `time_col` time default NULL, `tz` varchar(5) default NULL, `year` int(11) default NULL, `timestamp` timestamp NOT NULL default '0000-00-00 00:00:00', KEY `timestamp` (`timestamp`), KEY `queryindex` (`query`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"
  end

  def self.down
    # This is just to build the queries table locally on the development/test environments. We don't want to accidentally nuke the production table
    raise IrreversibleMigration  
  end
end
