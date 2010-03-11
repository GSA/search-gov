class AddLocaleToQueries < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE IF NOT EXISTS `queries` ( `ipaddr` varchar(17) default NULL, `query` varchar(100) default NULL, `affiliate` varchar(32) default NULL, `timestamp` timestamp NOT NULL default '0000-00-00 00:00:00', KEY `timestamp` (`timestamp`), KEY `queryindex` (`query`)) ENGINE=MyISAM DEFAULT CHARSET=latin1"  
    add_column :queries, :locale, :string, :limit => 5
  end

  def self.down
    remove_column :queries, :locale
  end
end
