class RemoveDefaultForDoctype < ActiveRecord::Migration
  def self.up
    update "ALTER TABLE `indexed_documents` CHANGE `doctype` `doctype` varchar(10) DEFAULT NULL"
  end

  def self.down
    update "ALTER TABLE `indexed_documents` CHANGE `doctype` `doctype` varchar(10) DEFAULT 'html'"
  end
end
