class RemoveAlwaysFilteredFlag < ActiveRecord::Migration
  def up
    remove_column :sayt_filters, :always_filtered
  end

  def down
    add_column :sayt_filters, :always_filtered, :boolean, :default => false, :null => false
  end
end
