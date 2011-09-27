class AddLocalIndexActiveToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :local_index_active, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :affiliates, :local_index_active
  end
end
