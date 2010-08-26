class ChangeCharsetOnQueriesTableToUtf8 < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE queries DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"
    execute "ALTER TABLE queries CONVERT TO CHARSET utf8 COLLATE utf8_unicode_ci"
  end

  def self.down
    execute "ALTER TABLE queries CONVERT TO CHARSET latin1"
    execute "ALTER TABLE queries DEFAULT CHARSET=latin1"
  end
end
