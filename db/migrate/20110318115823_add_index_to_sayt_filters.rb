class AddIndexToSaytFilters < ActiveRecord::Migration
  def self.up
    add_index :sayt_filters, :always_filtered
  end

  def self.down
    remove_index :sayt_filters, :always_filtered
  end
end
