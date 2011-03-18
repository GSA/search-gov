class AddAlwaysFilteredToSaytFilter < ActiveRecord::Migration
  def self.up
    add_column :sayt_filters, :always_filtered, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :sayt_filters, :always_filtered
  end
end
