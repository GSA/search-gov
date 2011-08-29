class SetCollationsOnSearchModuleTables < ActiveRecord::Migration
  def self.up
    execute %{ALTER TABLE search_modules MODIFY tag varchar(255) COLLATE utf8_unicode_ci NOT NULL}
    execute %{ALTER TABLE daily_search_module_stats MODIFY module_tag varchar(255) COLLATE utf8_unicode_ci NOT NULL}
  end

  def self.down
  end
end
