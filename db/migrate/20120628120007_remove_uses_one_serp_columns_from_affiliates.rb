class RemoveUsesOneSerpColumnsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :uses_one_serp
    remove_column :affiliates, :staged_uses_one_serp
  end

  def self.down
    add_column :affiliates, :staged_uses_one_serp, :boolean, :default => true
    add_column :affiliates, :uses_one_serp, :boolean, :default => true
  end
end
