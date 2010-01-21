class DropPropertyUsedFromClicks < ActiveRecord::Migration
  def self.up
    remove_column :clicks, :property_used
  end

  def self.down
    add_column :clicks, :property_used, :string
  end
end
