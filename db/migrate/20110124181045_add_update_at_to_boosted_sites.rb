class AddUpdateAtToBoostedSites < ActiveRecord::Migration
  def self.up
    add_column :boosted_sites, :updated_at, :datetime
    update("update boosted_sites set updated_at = created_at")
  end

  def self.down
    remove_column :boosted_sites, :updated_at
  end
end
