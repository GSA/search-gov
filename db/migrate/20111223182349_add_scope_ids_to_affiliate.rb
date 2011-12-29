class AddScopeIdsToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :scope_ids, :text
  end

  def self.down
    remove_column :affiliates, :scope_ids
  end
end
