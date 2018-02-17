class ChangeSearchgovUrlsUrlColumnCollation < ActiveRecord::Migration
  def up
    execute "ALTER TABLE searchgov_urls MODIFY url VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL"
  end

  def down
    execute "ALTER TABLE searchgov_urls MODIFY url VARCHAR(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL"
  end
end
