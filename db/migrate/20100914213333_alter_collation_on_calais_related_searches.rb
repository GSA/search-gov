class AlterCollationOnCalaisRelatedSearches < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `calais_related_searches` CHANGE `term` `term` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci"
    execute "ALTER TABLE `calais_related_searches` CHANGE `related_terms` `related_terms` VARCHAR( 4096 ) CHARACTER SET utf8 COLLATE utf8_general_ci"
  end

  def self.down
  end
end
