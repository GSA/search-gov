class DropLocalIndexActiveFromAffiliate < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :local_index_active
  end

  def self.down
    add_column :affiliates, :local_index_active, :boolean, :null => false, :default => false
  end
end
