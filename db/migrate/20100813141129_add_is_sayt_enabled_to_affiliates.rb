class AddIsSaytEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_sayt_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :affiliates, :is_sayt_enabled
  end
end
