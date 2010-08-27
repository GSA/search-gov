class ChangeCharsetOnQueriesTableToUtf8 < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE queries DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci, CONVERT TO CHARSET utf8 COLLATE utf8_unicode_ci"
  end

  def self.down
    execute "ALTER TABLE queries CONVERT TO CHARSET latin1, DEFAULT CHARSET=latin1"
  end
end
